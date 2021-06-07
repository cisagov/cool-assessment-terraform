# Security group for the STS interface endpoint in the private subnet
resource "aws_security_group" "sts" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "STS endpoint"
  }
}

# Allow ingress via HTTPS from the Gophish security group
resource "aws_security_group_rule" "ingress_from_gophish_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.sts.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.gophish.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Guacamole security group
resource "aws_security_group_rule" "ingress_from_guacamole_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.sts.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Nessus security group
resource "aws_security_group_rule" "ingress_from_nessus_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.sts.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nessus.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the Teamserver security group
resource "aws_security_group_rule" "ingress_from_teamserver_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.sts.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.teamserver.id
  from_port                = 443
  to_port                  = 443
}
