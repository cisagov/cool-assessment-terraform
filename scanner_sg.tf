# Security group for scanner instances.  These instances have
# unfettered egress and allow ingress from the TCP and UDP ports
# specified as allowed.
resource "aws_security_group" "scanner" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "Scanner"
  }
}

# Allow ingress from anywhere via ICMP
#
# For: Assessment team operational use
resource "aws_security_group_rule" "scanner_ingress_from_anywhere_via_icmp" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.scanner.id
  type              = "ingress"
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8
  to_port           = 0
}

# Allow egress to anywhere via any protocol and port
#
# For: Assessment team operational use
resource "aws_security_group_rule" "scanner_egress_to_anywhere_via_any_port" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.scanner.id
  type              = "egress"
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
}
