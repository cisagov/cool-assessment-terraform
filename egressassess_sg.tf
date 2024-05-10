# Security group for the Egress-Assess instances
resource "aws_security_group" "egressassess" {
  provider = aws.provisionassessment

  tags = {
    "Name" = "Egress-Assess"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress to anywhere via HTTP and HTTPS
#
# For: Package downloads and updates
resource "aws_security_group_rule" "egressassess_egress_to_anywhere_via_http_and_https" {
  for_each = toset(["80", "443"])
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.key
  protocol          = "tcp"
  security_group_id = aws_security_group.egressassess.id
  to_port           = each.key
  type              = "egress"
}

# Allow ingress from anywhere via all ICMP
#
# For: Assessment team operational use
resource "aws_security_group_rule" "ingress_from_anywhere_to_egressassess_via_all_icmp" {
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  protocol          = "icmp"
  security_group_id = aws_security_group.egressassess.id
  to_port           = -1
  type              = "ingress"
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_egressassess_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for d in var.inbound_ports_allowed["egressassess"] : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d }

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  protocol          = each.value["protocol"]
  security_group_id = aws_security_group.egressassess.id
  to_port           = each.value["to_port"]
  type              = "ingress"
}
