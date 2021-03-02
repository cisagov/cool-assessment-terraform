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

# Allow ingress from Kali instances via ports 993 and 50050 (IMAP over
# TLS/SSL and Cobalt Strike, respectively)
resource "aws_security_group_rule" "teamserver_ingress_from_kali_via_imaps_and_cs" {
  for_each = toset(["993", "50050"])
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.teamserver.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kali.id
  from_port                = each.key
  to_port                  = each.key
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_teamserver_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for index, d in var.inbound_ports_allowed["teamserver"] : index => d }

  security_group_id = aws_security_group.teamserver.id
  type              = "ingress"
  protocol          = each.value["protocol"]
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
}
