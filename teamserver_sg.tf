# Security group for the teamserver instances
resource "aws_security_group" "teamserver" {
  provider = aws.provisionassessment

  tags = {
    Name = "Teamserver"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress to Gophish instances via port 22 (SSH) for Ansible configuration
# and port 587 (SMTP mail submission) so that mail can be sent out via its mail
# server
resource "aws_security_group_rule" "teamserver_egress_to_gophish_via_ssh_and_smtp" {
  for_each = toset(["22", "587"])
  provider = aws.provisionassessment

  from_port                = each.key
  protocol                 = "tcp"
  security_group_id        = aws_security_group.teamserver.id
  source_security_group_id = aws_security_group.gophish.id
  to_port                  = each.key
  type                     = "egress"
}

# Allow ingress from Kali instances via ports 22, 993, and 50050 (SSH, IMAP over
# TLS/SSL, and Cobalt Strike, respectively)
resource "aws_security_group_rule" "teamserver_ingress_from_kali_via_ssh_imaps_and_cs" {
  for_each = toset(["22", "993", "50050"])
  provider = aws.provisionassessment

  from_port                = each.key
  protocol                 = "tcp"
  security_group_id        = aws_security_group.teamserver.id
  source_security_group_id = aws_security_group.kali.id
  to_port                  = each.key
  type                     = "ingress"
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_teamserver_via_allowed_ports" {
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for d in var.inbound_ports_allowed["teamserver"] : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d }
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  protocol          = each.value["protocol"]
  security_group_id = aws_security_group.teamserver.id
  to_port           = each.value["to_port"]
  type              = "ingress"
}

# Allow access between Teamserver and Kali instances on ports
# 5000-5999 (TCP and UDP).  This port range was requested for use by
# assessment operators in cisagov/cool-system-internal#79.
resource "aws_security_group_rule" "teamserver_egress_to_kali_instances_via_5000_to_5999" {
  for_each = toset(["tcp", "udp"])
  provider = aws.provisionassessment

  from_port                = 5000
  protocol                 = each.key
  security_group_id        = aws_security_group.teamserver.id
  source_security_group_id = aws_security_group.kali.id
  to_port                  = 5999
  type                     = "egress"
}
resource "aws_security_group_rule" "teamserver_ingress_from_kali_instances_via_5000_to_5999" {
  for_each = toset(["tcp", "udp"])
  provider = aws.provisionassessment

  from_port                = 5000
  protocol                 = each.key
  security_group_id        = aws_security_group.teamserver.id
  source_security_group_id = aws_security_group.kali.id
  to_port                  = 5999
  type                     = "ingress"
}

# Allow access between Teamserver and Windows instances on ports
# 5000-5999 (TCP only).  This port range was requested for use by
# assessment operators in cisagov/cool-system-internal#127 and
# cisagov/cool-assessment-terraform#235.
resource "aws_security_group_rule" "teamserver_egress_to_windows_instances_via_5000_to_5999_tcp" {
  provider = aws.provisionassessment

  from_port                = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.teamserver.id
  source_security_group_id = aws_security_group.windows.id
  to_port                  = 5999
  type                     = "egress"
}
resource "aws_security_group_rule" "teamserver_ingress_from_windows_instances_via_5000_to_5999_tcp" {
  provider = aws.provisionassessment

  from_port                = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.teamserver.id
  source_security_group_id = aws_security_group.windows.id
  to_port                  = 5999
  type                     = "ingress"
}
