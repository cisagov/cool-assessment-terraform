# Security group for the SSM interface endpoint (and other endpoints
# required when using the SSM service) in the private subnet
resource "aws_security_group" "ssm" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "SSM endpoints"
    },
  )
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

# Allow ingress via HTTPS from the guacamole security group
resource "aws_security_group_rule" "ingress_from_guacamole_to_ssm_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ssm.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the nessus security group
resource "aws_security_group_rule" "ingress_from_nessus_to_ssm_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ssm.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nessus.id
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
