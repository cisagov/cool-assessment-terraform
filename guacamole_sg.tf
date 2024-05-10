# Security group for Guacamole instances
resource "aws_security_group" "guacamole" {
  provider = aws.provisionassessment

  tags = {
    Name = "Guacamole (desktop gateway)"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress via SSH to instances that wish to be accessible via
# Guacamole
resource "aws_security_group_rule" "guacamole_egress_to_hosts_via_ssh" {
  provider = aws.provisionassessment

  from_port                = 22
  security_group_id        = aws_security_group.guacamole.id
  source_security_group_id = aws_security_group.guacamole_accessible.id
  protocol                 = "tcp"
  to_port                  = 22
  type                     = "egress"
}

# Allow egress via VNC to instances that wish to be accessible via
# Guacamole
resource "aws_security_group_rule" "guacamole_egress_to_hosts_via_vnc" {
  provider = aws.provisionassessment

  from_port                = 5901
  protocol                 = "tcp"
  security_group_id        = aws_security_group.guacamole.id
  source_security_group_id = aws_security_group.guacamole_accessible.id
  to_port                  = 5901
  type                     = "egress"
}

# Allow ingress from COOL Shared Services VPN server CIDR block
# via HTTPS
#
# For: Assessment team access to Guacamole web client
resource "aws_security_group_rule" "guacamole_ingress_from_trusted_via_https" {
  provider = aws.provisionassessment

  cidr_blocks = [local.vpn_server_cidr_block]
  # ipv6_cidr_blocks  = TBD
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.guacamole.id
  to_port           = 443
  type              = "ingress"
}

# Allow egress to COOL Shared Services via IPA-related ports
#
# For: Guacamole instance communication with FreeIPA
resource "aws_security_group_rule" "guacamole_egress_to_cool_via_ipa_ports" {
  provider = aws.provisionassessment
  for_each = local.ipa_ports

  cidr_blocks       = [local.cool_shared_services_cidr_block]
  from_port         = each.value.port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.guacamole.id
  to_port           = each.value.port
  type              = "egress"
}
