# Security group for the Nessus instances
resource "aws_security_group" "nessus" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "Nessus"
  }
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

# Allow ingress from Windows instances via Nessus web GUI
#
# For: Assessment team Nessus web access from Windows instances
resource "aws_security_group_rule" "nessus_ingress_from_windows_via_web_ui" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.nessus.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.windows.id
  from_port                = 8834
  to_port                  = 8834
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_nessus_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for index, d in var.inbound_ports_allowed["nessus"] : index => d }

  security_group_id = aws_security_group.nessus.id
  type              = "ingress"
  protocol          = each.value["protocol"]
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
}
