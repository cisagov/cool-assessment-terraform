# Security group for the teamserver instances
resource "aws_security_group" "teamserver" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Teamserver"
    },
  )
}

# Allow ingress from Kali instances via port 993 (IMAP over TLS/SSL)
resource "aws_security_group_rule" "teamserver_ingress_from_kali_via_imaps" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.teamserver.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kali.id
  from_port                = 993
  to_port                  = 993
}

# Allow ingress from Kali instances via port 50050 (Cobalt Strike)
resource "aws_security_group_rule" "teamserver_ingress_from_kali_via_cs" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.teamserver.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kali.id
  from_port                = 50050
  to_port                  = 50050
}
