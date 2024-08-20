# Security group for the Kali Linux instances
resource "aws_security_group" "kali" {
  provider = aws.provisionassessment

  tags = {
    Name = "Kali"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress to and ingress from other Kali instances via port 22
resource "aws_security_group_rule" "kali_to_kali_via_ssh" {
  for_each = toset(["egress", "ingress"])
  provider = aws.provisionassessment

  from_port                = "22"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.kali.id
  source_security_group_id = aws_security_group.kali.id
  to_port                  = "22"
  type                     = each.key
}

# Allow egress to PenTest Portal instances via ports 443 and 8080
resource "aws_security_group_rule" "kali_egress_to_pentestportal_via_web" {
  for_each = toset(["443", "8080"])
  provider = aws.provisionassessment

  from_port                = each.key
  protocol                 = "tcp"
  security_group_id        = aws_security_group.kali.id
  source_security_group_id = aws_security_group.pentestportal.id
  to_port                  = each.key
  type                     = "egress"
}

# Allow egress to teamservers via ports 22, 993, and 50050 (SSH, IMAP over
# TLS/SSL, and Cobalt Strike, respectively)
resource "aws_security_group_rule" "kali_egress_to_teamserver_via_ssh_imaps_and_cs" {
  for_each = toset(["22", "993", "50050"])
  provider = aws.provisionassessment

  from_port                = each.key
  protocol                 = "tcp"
  security_group_id        = aws_security_group.kali.id
  source_security_group_id = aws_security_group.teamserver.id
  to_port                  = each.key
  type                     = "egress"
}

# Allow egress to Nessus instances via port 8834 (the default port
# used by the Nessus web UI)
resource "aws_security_group_rule" "kali_egress_to_nessus_via_web_ui" {
  provider = aws.provisionassessment

  from_port                = 8834
  security_group_id        = aws_security_group.kali.id
  source_security_group_id = aws_security_group.nessus.id
  protocol                 = "tcp"
  to_port                  = 8834
  type                     = "egress"
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_kali_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for d in var.inbound_ports_allowed["kali"] : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d }

  security_group_id = aws_security_group.kali.id
  type              = "ingress"
  protocol          = each.value["protocol"]
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  to_port           = each.value["to_port"]
}

# Allow access between Kali and Teamserver instances on ports
# 5000-5999 (TCP and UDP).  This port range was requested for use by
# assessment operators in cisagov/cool-system-internal#79.
resource "aws_security_group_rule" "kali_egress_to_teamserver_instances_via_5000_to_5999" {
  provider = aws.provisionassessment
  for_each = toset(["tcp", "udp"])

  security_group_id        = aws_security_group.kali.id
  type                     = "egress"
  protocol                 = each.key
  source_security_group_id = aws_security_group.teamserver.id
  from_port                = 5000
  to_port                  = 5999
}
resource "aws_security_group_rule" "kali_ingress_from_teamserver_instances_via_5000_to_5999" {
  provider = aws.provisionassessment
  for_each = toset(["tcp", "udp"])

  security_group_id        = aws_security_group.kali.id
  type                     = "ingress"
  protocol                 = each.key
  source_security_group_id = aws_security_group.teamserver.id
  from_port                = 5000
  to_port                  = 5999
}

# Allow unfettered access between Kali and Windows instances
resource "aws_security_group_rule" "kali_egress_to_windows_instances" {
  provider = aws.provisionassessment
  for_each = toset(["tcp", "udp"])

  security_group_id        = aws_security_group.kali.id
  type                     = "egress"
  protocol                 = each.key
  source_security_group_id = aws_security_group.windows.id
  from_port                = 0
  to_port                  = 65535
}
resource "aws_security_group_rule" "kali_ingress_from_windows_instances" {
  provider = aws.provisionassessment
  for_each = toset(["tcp", "udp"])

  security_group_id        = aws_security_group.kali.id
  type                     = "ingress"
  protocol                 = each.key
  source_security_group_id = aws_security_group.windows.id
  from_port                = 0
  to_port                  = 65535
}
