# Allow ingress from COOL Shared Services VPN server CIDR block via https
# For: Assessment team access to guacamole web client
resource "aws_network_acl_rule" "private_ingress_from_cool_vpn_via_https" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 102 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = local.vpn_server_cidr_block
  from_port      = 443
  to_port        = 443
}

# Allow egress to anywhere via HTTPS
#
# For: Guacamole fetches its SSL certificate via boto3 (which uses
# HTTPS).  It also needs to download the Docker images used in the
# guacamole Docker composition.
resource "aws_network_acl_rule" "private_egress_to_anywhere_via_https" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 104 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow egress to COOL Shared Services via ephemeral ports
# For: Assessment team access to guacamole web client
resource "aws_network_acl_rule" "private_egress_to_cool_via_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 106 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = local.cool_shared_services_cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow egress to operations subnet via ephemeral ports, for EFS
# access.  (EFS is just NFS under the hood.)
resource "aws_network_acl_rule" "private_egress_to_operations_via_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 108 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
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
  rule_number    = 110 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 22
  to_port        = 22
}

# Allow ingress from operations subnet via ephemeral ports
# For: DevOps ssh access from private subnet to operations subnet and
#      Assessment team VNC access from private subnet to operations subnet
#
# Note that this also covers ingress from the operations subnet via
# TCP port 2049 for EFS.
resource "aws_network_acl_rule" "private_ingress_from_operations_via_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 112 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow ingress from anywhere via ephemeral ports, modulo port 2049
# which is used for EFS.
#
# For: Guacamole fetches its SSL certificate via boto3 (which uses
# HTTPS)
resource "aws_network_acl_rule" "private_ingress_from_anywhere_via_ephemeral_ports_1" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 114 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 2048
}
resource "aws_network_acl_rule" "private_ingress_from_anywhere_via_ephemeral_ports_2" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 120 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 2050
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
  rule_number    = 130 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 5901
  to_port        = 5901
}

# Allow egress to COOL Shared Services via IPA-related ports
# For: Guacamole instance communication with FreeIPA
# Note that these rules only apply to the private subnet with Guacamole.
resource "aws_network_acl_rule" "private_egress_to_cool_via_ipa_ports" {
  provider = aws.provisionassessment
  for_each = local.ipa_ports

  network_acl_id = aws_network_acl.private[var.private_subnet_cidr_blocks[0]].id
  egress         = true
  protocol       = each.value.proto
  rule_number    = 140 + each.value.index
  rule_action    = "allow"
  cidr_block     = local.cool_shared_services_cidr_block
  from_port      = each.value.port
  to_port        = each.value.port
}

# Allow ingress from private subnet to private subnet via IPA-related ports.
# For: Guacamole instance communication with FreeIPA
# Note that these rules only apply to the private subnet with Guacamole.
# Full disclosure: We are not totally clear on why this access is needed,
# but without it, traffic is unable to go from the Guacamole instance to the
# Transit Gateway attachment (both reside in the same private subnet).
resource "aws_network_acl_rule" "private_ingress_to_tg_attachment_via_ipa_ports" {
  provider = aws.provisionassessment
  for_each = local.ipa_ports

  network_acl_id = aws_network_acl.private[var.private_subnet_cidr_blocks[0]].id
  egress         = false
  protocol       = each.value.proto
  rule_number    = 150 + each.value.index
  rule_action    = "allow"
  cidr_block     = var.private_subnet_cidr_blocks[0]
  from_port      = each.value.port
  to_port        = each.value.port
}

# Allow ingress from the operations subnet via https
#
# For: Operations subnet access to VPC endpoints
resource "aws_network_acl_rule" "private_ingress_from_operations_via_https" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 160 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 443
  to_port        = 443
}
