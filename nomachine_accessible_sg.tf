# Security group for the instances accessible by NoMachine
resource "aws_security_group" "nomachine_accessible" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "NoMachine accessible"
  }
}

# Allow ingress from COOL Shared Services VPN server CIDR block
# via NX protocol.
#
# For: Assessment team access via NoMachine Cloud Server
resource "aws_security_group_rule" "nomachine_ingress_from_cloud_server_via_nx" {
  provider = aws.provisionassessment
  for_each = local.nomachine_ports

  security_group_id        = aws_security_group.nomachine_accessible.id
  type                     = "ingress"
  protocol                 = each.value.protocol
  source_security_group_id = aws_security_group.nomachine.id
  # ipv6_cidr_blocks  = TBD
  from_port = each.value.from_port
  to_port   = each.value.to_port
}
