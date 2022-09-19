# Security group for NoMachine Cloud Server instances
resource "aws_security_group" "nomachine" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "NoMachine (desktop gateway)"
  }
}

# Allow egress via NX to instances that wish to be accessible via
# NoMachine
resource "aws_security_group_rule" "nomachine_egress_to_hosts_via_nx" {
  provider = aws.provisionassessment
  for_each = local.nomachine_ports

  security_group_id        = aws_security_group.nomachine.id
  type                     = "egress"
  protocol                 = each.value.protocol
  source_security_group_id = aws_security_group.nomachine_accessible.id
  # ipv6_cidr_blocks  = TBD
  from_port = each.value.from_port
  to_port   = each.value.to_port
}

# Allow ingress from COOL Shared Services VPN server CIDR block
# via NX
#
# For: Assessment team access to Guacamole web client
resource "aws_security_group_rule" "nomachine_ingress_from_trusted_via_nx" {
  provider = aws.provisionassessment
  for_each = local.nomachine_ports

  security_group_id = aws_security_group.nomachine.id
  type              = "ingress"
  protocol          = each.value.protocol
  cidr_blocks       = [local.vpn_server_cidr_block]
  # ipv6_cidr_blocks  = TBD
  from_port = each.value.from_port
  to_port   = each.value.to_port
}

# # Allow egress to COOL Shared Services via IPA-related ports
# #
# # For: Guacamole instance communication with FreeIPA
# resource "aws_security_group_rule" "guacamole_egress_to_cool_via_ipa_ports" {
#   provider = aws.provisionassessment
#   for_each = local.ipa_ports

#   security_group_id = aws_security_group.guacamole.id
#   type              = "egress"
#   protocol          = each.value.protocol
#   cidr_blocks       = [local.cool_shared_services_cidr_block]
#   from_port         = each.value.port
#   to_port           = each.value.port
# }
