# Security group for the CloudWatch interface endpoints in the private
# subnet
resource "aws_security_group" "cloudwatch" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "CloudWatch endpoints"
  }
}

# Allow ingress via HTTPS from the Debian Desktop security group
resource "aws_security_group_rule" "ingress_from_debiandesktop_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.debiandesktop.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Gophish security group
resource "aws_security_group_rule" "ingress_from_gophish_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.gophish.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Guacamole security group
resource "aws_security_group_rule" "ingress_from_guacamole_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Kali security group
resource "aws_security_group_rule" "ingress_from_kali_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kali.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Nessus security group
resource "aws_security_group_rule" "ingress_from_nessus_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nessus.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the PenTest Portal security group
resource "aws_security_group_rule" "ingress_from_pentestportal_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.pentestportal.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Samba security group
resource "aws_security_group_rule" "ingress_from_samba_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.smb_server.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the teamserver security group
resource "aws_security_group_rule" "ingress_from_teamserver_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.teamserver.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the terraformer security group
resource "aws_security_group_rule" "ingress_from_terraformer_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.terraformer.id
  from_port                = 443
  to_port                  = 443
}
