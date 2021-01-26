# Security group for the Debian desktop instances
resource "aws_security_group" "debiandesktop" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Debian Desktop"
    },
  )
}

# Allow egress to Nessus web GUI port (8834)
#
# For: Operator Nessus web access from Debian desktop instances
resource "aws_security_group_rule" "debiandesktop_egress_to_nessus_via_gui_port" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.debiandesktop.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nessus.id
  from_port                = 8834
  to_port                  = 8834
}

# Allow egress to anywhere via HTTP and HTTPS
#
# For: Operator web access, package downloads and updates
resource "aws_security_group_rule" "debiandesktop_egress_to_anywhere_via_http_and_https" {
  for_each = toset(["80", "443"])
  provider = aws.provisionassessment

  security_group_id = aws_security_group.debiandesktop.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.key
  to_port           = each.key
}
