# Allow ingress from COOL via ssh
# For: DevOps ssh access to private subnet
resource "aws_network_acl_rule" "private_ingress_from_cool_via_ssh" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 100 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = var.cool_cidr_block
  from_port      = 22
  to_port        = 22
}

# Allow egress to anywhere via HTTPS
# For: Guacamole fetches its SSL certificate via boto3 (which uses HTTPS)
resource "aws_network_acl_rule" "private_egress_to_anywhere_via_https" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 102 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow egress to COOL via ephemeral ports
# For: DevOps ssh access to private subnet
resource "aws_network_acl_rule" "private_egress_to_cool_via_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 104 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = var.cool_cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow egress to operations subnet via ssh
# For: DevOps ssh access from private subnet to operations subnet
resource "aws_network_acl_rule" "private_egress_to_operations_via_ssh" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 106 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 22
  to_port        = 22
}

# Allow ingress from operations subnet via ephemeral ports
# For: DevOps ssh access from private subnet to operations subnet and
#      Assessment team VNC access from private subnet to operations subnet
resource "aws_network_acl_rule" "private_ingress_from_operations_via_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 108 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow ingress from anywhere via ephemeral ports
# For: Assessment team access to guacamole web client
#      Guacamole fetches its SSL certificate via boto3 (which uses HTTPS)
resource "aws_network_acl_rule" "private_ingress_from_anywhere_via_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 110 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow egress to operations subnet via VNC
# For: Assessment team VNC access from private subnet to operations subnet
resource "aws_network_acl_rule" "private_egress_to_operations_via_vnc" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 120 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 5901
  to_port        = 5901
}
