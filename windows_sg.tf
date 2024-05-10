# Security group for the Windows instances
resource "aws_security_group" "windows" {
  provider = aws.provisionassessment

  tags = {
    Name = "Windows"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress to PenTest Portal instances via ports 443 and 8080
resource "aws_security_group_rule" "windows_egress_to_pentestportal_via_web" {
  for_each = toset(["443", "8080"])
  provider = aws.provisionassessment

  from_port                = each.key
  protocol                 = "tcp"
  security_group_id        = aws_security_group.windows.id
  source_security_group_id = aws_security_group.pentestportal.id
  to_port                  = each.key
  type                     = "egress"
}

# Allow egress to Nessus instances via port 8834 (the default port
# used by the Nessus web UI)
resource "aws_security_group_rule" "windows_egress_to_nessus_via_web_ui" {
  provider = aws.provisionassessment

  from_port                = 8834
  protocol                 = "tcp"
  security_group_id        = aws_security_group.windows.id
  source_security_group_id = aws_security_group.nessus.id
  to_port                  = 8834
  type                     = "egress"
}

# Allow ingress from anywhere via the allowed ports
resource "aws_security_group_rule" "ingress_from_anywhere_to_windows_via_allowed_ports" {
  provider = aws.provisionassessment
  # for_each will only accept a map or a list of strings, so we have
  # to do a little finagling to get the list of port objects into an
  # acceptable form.
  for_each = { for d in var.inbound_ports_allowed["windows"] : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d }

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value["from_port"]
  protocol          = each.value["protocol"]
  security_group_id = aws_security_group.windows.id
  to_port           = each.value["to_port"]
  type              = "ingress"
}

# Allow unfettered access between Windows and Kali instances
resource "aws_security_group_rule" "windows_egress_to_kali_instances" {
  provider = aws.provisionassessment
  for_each = toset(["tcp", "udp"])

  from_port                = 0
  protocol                 = each.key
  security_group_id        = aws_security_group.windows.id
  source_security_group_id = aws_security_group.kali.id
  to_port                  = 65535
  type                     = "egress"
}
resource "aws_security_group_rule" "windows_ingress_from_kali_instances" {
  provider = aws.provisionassessment
  for_each = toset(["tcp", "udp"])

  from_port                = 0
  protocol                 = each.key
  security_group_id        = aws_security_group.windows.id
  source_security_group_id = aws_security_group.kali.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow access between Windows and Teamserver instances on ports
# 5000-5999 (TCP only).  This port range was requested for use by
# assessment operators in cisagov/cool-system-internal#127 and
# cisagov/cool-assessment-terraform#235.
resource "aws_security_group_rule" "windows_egress_to_teamserver_instances_via_5000_to_5999_tcp" {
  provider = aws.provisionassessment

  from_port                = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.windows.id
  source_security_group_id = aws_security_group.teamserver.id
  to_port                  = 5999
  type                     = "egress"
}
resource "aws_security_group_rule" "windows_ingress_from_teamserver_instances_via_5000_to_5999_tcp" {
  provider = aws.provisionassessment

  from_port                = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.windows.id
  source_security_group_id = aws_security_group.teamserver.id
  to_port                  = 5999
  type                     = "ingress"
}
