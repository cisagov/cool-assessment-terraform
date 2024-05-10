# Security group for the Debian desktop instances
resource "aws_security_group" "debiandesktop" {
  provider = aws.provisionassessment

  tags = {
    "Name" = "Debian Desktop"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress to Nessus web GUI port (8834)
#
# For: Assessment team Nessus web access from Debian desktop instances
resource "aws_security_group_rule" "debiandesktop_egress_to_nessus_via_web_ui" {
  provider = aws.provisionassessment

  from_port                = 8834
  protocol                 = "tcp"
  security_group_id        = aws_security_group.debiandesktop.id
  source_security_group_id = aws_security_group.nessus.id
  to_port                  = 8834
  type                     = "egress"
}

# Allow egress to anywhere via HTTP and HTTPS
#
# For: Assessment team web access, package downloads and updates
resource "aws_security_group_rule" "debiandesktop_egress_to_anywhere_via_http_and_https" {
  for_each = toset(["80", "443"])
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.key
  protocol          = "tcp"
  security_group_id = aws_security_group.debiandesktop.id
  to_port           = each.key
  type              = "egress"
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_debiandesktop_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for d in var.inbound_ports_allowed["debiandesktop"] : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d }

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  protocol          = each.value["protocol"]
  security_group_id = aws_security_group.debiandesktop.id
  to_port           = each.value["to_port"]
  type              = "ingress"
}
