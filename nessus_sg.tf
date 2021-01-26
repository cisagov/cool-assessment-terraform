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

# Allow ingress from Debian desktop instances via Nessus web GUI port
# (8834)
#
# For: Operator Nessus web access from Debian desktop instances
resource "aws_security_group_rule" "nessus_ingress_from_debiandesktop_via_gui_port" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.nessus.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.debiandesktop.id
  from_port                = 8834
  to_port                  = 8834
}
