# Security group for the teamserver instances
resource "aws_security_group" "teamserver" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "Teamserver"
  }
}

# Allow egress via port 587 (SMTP mail submission) to Gophish instances
# so that mail can be sent out via its mail server
resource "aws_security_group_rule" "teamserver_egress_to_gophish_via_587" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.teamserver.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.gophish.id
  from_port                = 587
  to_port                  = 587
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
  for_each = { for d in var.inbound_ports_allowed["teamserver"] : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d }

  security_group_id = aws_security_group.teamserver.id
  type              = "ingress"
  protocol          = each.value["protocol"]
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
}

# Allow access between Teamserver and Kali instances on ports
# 5000-5999 (TCP and UDP).  This port range was requested for use by
# assessment operators in cisagov/cool-system-internal#79.
resource "aws_security_group_rule" "teamserver_egress_to_kali_instances_via_5000_to_5999" {
  provider = aws.provisionassessment
  for_each = toset(["tcp", "udp"])

  security_group_id        = aws_security_group.teamserver.id
  type                     = "egress"
  protocol                 = each.key
  source_security_group_id = aws_security_group.kali.id
  from_port                = 5000
  to_port                  = 5999
}
resource "aws_security_group_rule" "teamserver_ingress_from_kali_instances_via_5000_to_5999" {
  provider = aws.provisionassessment
  for_each = toset(["tcp", "udp"])

  security_group_id        = aws_security_group.teamserver.id
  type                     = "ingress"
  protocol                 = each.key
  source_security_group_id = aws_security_group.kali.id
  from_port                = 5000
  to_port                  = 5999
}

# Allow access between Teamserver and Windows instances on ports
# 5000-5999 (TCP only).  This port range was requested for use by
# assessment operators in cisagov/cool-system-internal#127 and
# cisagov/cool-assessment-terraform#235.
resource "aws_security_group_rule" "teamserver_egress_to_windows_instances_via_5000_to_5999_tcp" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.teamserver.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.windows.id
  from_port                = 5000
  to_port                  = 5999
}
resource "aws_security_group_rule" "teamserver_ingress_from_windows_instances_via_5000_to_5999_tcp" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.teamserver.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.windows.id
  from_port                = 5000
  to_port                  = 5999
}
