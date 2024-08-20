# Security group for Gophish instances
resource "aws_security_group" "gophish" {
  provider = aws.provisionassessment

  tags = {
    Name = "Gophish"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow ingress from Kali instances via port 22 (SSH) for Ansible configuration
resource "aws_security_group_rule" "ingress_from_kali_via_ssh" {
  provider = aws.provisionassessment

  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.gophish.id
  source_security_group_id = aws_security_group.kali.id
  to_port                  = 22
  type                     = "ingress"
}

# Allow ingress from Teamserver instances via port 587 (SMTP mail submission)
# so mail can be sent via the mail server on Gophish instances
resource "aws_security_group_rule" "ingress_from_teamserver_to_gophish_via_smtp" {
  provider = aws.provisionassessment

  from_port                = 587
  protocol                 = "tcp"
  security_group_id        = aws_security_group.gophish.id
  source_security_group_id = aws_security_group.teamserver.id
  to_port                  = 587
  type                     = "ingress"
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_gophish_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for d in var.inbound_ports_allowed["gophish"] : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d }

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  protocol          = each.value["protocol"]
  security_group_id = aws_security_group.gophish.id
  to_port           = each.value["to_port"]
  type              = "ingress"
}
