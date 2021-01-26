# Security group for the operations instances
resource "aws_security_group" "operations" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Operations"
    },
  )
}

# Allow ingress from anywhere via the TCP ports specified in
# var.operations_subnet_inbound_tcp_ports_allowed
# For: Assessment team operational use
resource "aws_security_group_rule" "operations_ingress_from_anywhere_via_allowed_tcp_ports" {
  provider = aws.provisionassessment
  for_each = local.operations_subnet_inbound_tcp_ports_allowed

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from"]
  to_port           = each.value["to"]
}

# Allow ingress from anywhere via the UDP ports specified in
# var.operations_subnet_inbound_udp_ports_allowed
# For: Assessment team operational use
resource "aws_security_group_rule" "operations_ingress_from_anywhere_via_allowed_udp_ports" {
  provider = aws.provisionassessment
  for_each = local.operations_subnet_inbound_udp_ports_allowed

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from"]
  to_port           = each.value["to"]
}

# Allow ingress from anywhere via ICMP
# For: Assessment team operational use (e.g. ping responses)
resource "aws_security_group_rule" "operations_ingress_from_anywhere_via_icmp" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
}

# Allow egress to anywhere via any protocol and port
# For: Assessment team operational use
resource "aws_security_group_rule" "operations_egress_to_anywhere_via_any_port" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.operations.id
  type              = "egress"
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
}
