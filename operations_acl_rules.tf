# Allow ingress from private subnet via ssh
#
# For: DevOps ssh access from private subnet to operations subnet.
# This is also necessary so that the Terraformer instance can
# configure instances in the operations subnet via Ansible.
resource "aws_network_acl_rule" "operations_ingress_from_private_via_ssh" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 100 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.private[each.value].cidr_block
  from_port      = 22
  to_port        = 22
}

# Allow ingress from private subnet via port 5986 (Windows Remote
# Management).
#
# For: This is necessary so that the Terraformer instance can
# configure Windows instances in the operations subnet via Ansible.
resource "aws_network_acl_rule" "operations_ingress_from_private_via_winrm" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 110 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.private[each.value].cidr_block
  from_port      = 5986
  to_port        = 5986
}
# Disallow ingress from anywhere else via port 5986 (Windows Remote
# Management).
resource "aws_network_acl_rule" "operations_ingress_from_anywhere_else_winrm" {
  provider = aws.provisionassessment

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 115
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 5986
  to_port        = 5986
}

# Allow ingress from private subnet via VNC
#
# For: Assessment team VNC access from private subnet to operations.
# subnet
resource "aws_network_acl_rule" "operations_ingress_from_private_via_vnc" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 120 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.private[each.value].cidr_block
  from_port      = 5901
  to_port        = 5901
}
# Disallow ingress from anywhere else via VNC.
resource "aws_network_acl_rule" "operations_ingress_from_anywhere_else_vnc" {
  provider = aws.provisionassessment

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 125
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 5901
  to_port        = 5901
}

# Allow ingress from the private subnets via port 80.  This is
# necessary so that the Terraformer instance can install packages via
# the NAT gateway.
resource "aws_network_acl_rule" "operations_ingress_from_private_via_http" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 130 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.private[each.value].cidr_block
  from_port      = 80
  to_port        = 80
}

# Allow ingress from the private subnets via port 443.  This is
# necessary so that the Terraformer instance can perform a terraform
# init via the NAT gateway.
resource "aws_network_acl_rule" "operations_ingress_from_private_via_https" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 140 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.private[each.value].cidr_block
  from_port      = 443
  to_port        = 443
}

# Allow ingress from anywhere via the ports specified in
# var.inbound_ports_allowed
#
# For: Assessment team operational use
resource "aws_network_acl_rule" "operations_ingress_from_anywhere_via_allowed_ports" {
  provider = aws.provisionassessment
  for_each = local.union_of_inbound_ports_allowed

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = each.value.protocol
  rule_number    = 150 + each.value.index
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# Allow ingress from anywhere via ephemeral TCP/UDP ports below 3389
# (1024-3388)
#
# For: Assessment team operational use, but we don't want to allow
# public access to RDP on port 3389.
resource "aws_network_acl_rule" "operations_ingress_from_anywhere_via_ports_1024_thru_3388" {
  provider = aws.provisionassessment
  for_each = toset(local.tcp_and_udp)

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = each.value
  rule_number    = 170 + index(local.tcp_and_udp, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 3388
}

# Allow ingress from anywhere via ephemeral TCP/UDP ports 3390-50049.
#
# For: Assessment team operational use, but we don't want to allow
# public access to RDP on port 3389 or Cobalt Strike Teamservers on port 50050.
#
# We can skip the VNC and WinRM ports as they are blocked by rules above.
resource "aws_network_acl_rule" "operations_ingress_from_anywhere_via_ports_3390_thru_50049" {
  provider = aws.provisionassessment
  for_each = toset(local.tcp_and_udp)

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = each.value
  rule_number    = 180 + index(local.tcp_and_udp, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3390
  to_port        = 50049
}

# Allow ingress from anywhere via ephemeral TCP/UDP ports 50051-65535.
#
# For: Assessment team operational use, but we don't want to allow
# public access to Cobalt Strike Teamservers on port 50050.
resource "aws_network_acl_rule" "operations_ingress_from_anywhere_via_ports_50051_thru_65535" {
  provider = aws.provisionassessment
  for_each = toset(local.tcp_and_udp)

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = each.value
  rule_number    = 200 + index(local.tcp_and_udp, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 50051
  to_port        = 65535
}

# Allow ingress from anywhere via ICMP
#
# For: Assessment team operational use (e.g. ping responses)
resource "aws_network_acl_rule" "operations_ingress_from_anywhere_via_icmp" {
  provider = aws.provisionassessment

  network_acl_id = aws_network_acl.operations.id
  egress         = false
  protocol       = "icmp"
  rule_number    = 210
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = -1
  icmp_code      = -1
}

# Allow egress to anywhere via any protocol and port
#
# For: Assessment team operational use
#
# Note that this also covers the return traffic when the Terraformer
# instance performs a terraform init or installs packages via the NAT
# gateway in the operations subnet.
resource "aws_network_acl_rule" "operations_egress_to_anywhere_via_any_port" {
  provider = aws.provisionassessment

  network_acl_id = aws_network_acl.operations.id
  egress         = true
  protocol       = "-1"
  rule_number    = 300
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
