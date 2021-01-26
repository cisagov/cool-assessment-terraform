# Allow ingress via HTTPS from the desktop gateway security group
resource "aws_security_group_rule" "ingress_from_desktop_gw_to_ssm_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ssm.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.desktop_gateway.id
  from_port                = 443
  to_port                  = 443
}


# Allow ingress via HTTPS from the operations security group
resource "aws_security_group_rule" "ingress_from_operations_to_ssm_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ssm.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.operations.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the PenTest Portal security group
resource "aws_security_group_rule" "ingress_from_pentestportal_to_ssm_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ssm.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.pentestportal.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Debian Desktop security group
resource "aws_security_group_rule" "ingress_from_debiandesktop_to_ssm_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ssm.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.debiandesktop.id
  from_port                = 443
  to_port                  = 443
}
