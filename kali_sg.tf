# Security group for the Kali Linux instances
resource "aws_security_group" "kali" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Kali"
    },
  )
}

# Allow egress to teamservers via port 993 (IMAP over TLS/SSL)
resource "aws_security_group_rule" "kali_egress_to_teamserver_via_imaps" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.kali.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.teamserver.id
  from_port                = 993
  to_port                  = 993
}

# Allow egress to teamservers via port 50050 (Cobalt Strike)
resource "aws_security_group_rule" "kali_egress_to_teamserver_via_cs" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.kali.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.teamserver.id
  from_port                = 50050
  to_port                  = 50050
}
