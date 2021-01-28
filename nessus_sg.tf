# Security group for the Nessus instances
resource "aws_security_group" "nessus" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Nessus"
    },
  )
}

# Allow ingress from Debian desktop instances via Nessus web GUI
#
# For: Assessment team Nessus web access from Debian desktop instances
resource "aws_security_group_rule" "nessus_ingress_from_debiandesktop_via_web_ui" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.nessus.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.debiandesktop.id
  from_port                = 8834
  to_port                  = 8834
}

# Allow ingress from Kali instances via Nessus web GUI
#
# For: Assessment team Nessus web access from Kali instances
resource "aws_security_group_rule" "nessus_ingress_from_kali_via_web_ui" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.nessus.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kali.id
  from_port                = 8834
  to_port                  = 8834
}
