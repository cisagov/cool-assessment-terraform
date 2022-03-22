# Security group for the Assessor Portal instances
resource "aws_security_group" "assessorportal" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    "Name" = "Assessor Portal"
  }
}

# Allow egress to anywhere via HTTP and HTTPS
#
# For: Assessment team web access, package downloads and updates
resource "aws_security_group_rule" "assessorportal_egress_to_anywhere_via_http_and_https" {
  for_each = toset(["80", "443"])
  provider = aws.provisionassessment

  security_group_id = aws_security_group.assessorportal.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.key
  to_port           = each.key
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_assessorportal_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for d in var.inbound_ports_allowed["assessorportal"] : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d }

  security_group_id = aws_security_group.assessorportal.id
  type              = "ingress"
  protocol          = each.value["protocol"]
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
}
