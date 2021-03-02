# Security group for Gophish instances
resource "aws_security_group" "gophish" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Gophish"
    },
  )
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_gophish_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for index, d in var.inbound_ports_allowed["gophish"] : index => d }

  security_group_id = aws_security_group.gophish.id
  type              = "ingress"
  protocol          = each.value["protocol"]
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
}
