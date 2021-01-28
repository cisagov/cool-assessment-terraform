# Security group for the Kali Linux instances
resource "aws_security_group" "kali" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Kali"
    },
  )
}

# Allow egress to PenTest Portal instances via ports 443 and 8080
resource "aws_security_group_rule" "kali_egress_to_pentestportal_via_web" {
  for_each = toset(["443", "8080"])
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.kali.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.pentestportal.id
  from_port                = each.key
  to_port                  = each.key
}

# Allow egress to teamservers via ports 993 and 50050 (IMAP over
# TLS/SSL and Cobalt Strike, respectively)
resource "aws_security_group_rule" "kali_egress_to_teamserver_via_imaps_and_cs" {
  for_each = toset(["993", "50050"])
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.kali.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.teamserver.id
  from_port                = each.key
  to_port                  = each.key
}

# Allow egress to Nessus instances via port 8834 (the default port
# used by the Nessus web UI)
resource "aws_security_group_rule" "kali_egress_to_nessus_via_web_ui" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.kali.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nessus.id
  from_port                = 8834
  to_port                  = 8834
}
