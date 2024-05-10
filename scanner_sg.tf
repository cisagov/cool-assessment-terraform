# Security group for scanner instances.  These instances have
# unfettered egress and allow ingress from the TCP and UDP ports
# specified as allowed.
resource "aws_security_group" "scanner" {
  provider = aws.provisionassessment

  tags = {
    Name = "Scanner"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow ingress from anywhere via ICMP
#
# For: Assessment team operational use
resource "aws_security_group_rule" "scanner_ingress_from_anywhere_via_icmp" {
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8
  protocol          = "icmp"
  security_group_id = aws_security_group.scanner.id
  to_port           = 0
  type              = "ingress"
}

# Allow egress to anywhere via any protocol and port
#
# For: Assessment team operational use
resource "aws_security_group_rule" "scanner_egress_to_anywhere_via_any_port" {
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  protocol          = -1
  security_group_id = aws_security_group.scanner.id
  to_port           = -1
  type              = "egress"
}
