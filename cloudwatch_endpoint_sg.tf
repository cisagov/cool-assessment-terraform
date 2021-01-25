# Security group for the CloudWatch interface endpoints in the private
# subnet
resource "aws_security_group" "cloudwatch" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "CloudWatch endpoints"
    },
  )
}

# Allow ingress via HTTPS from the guacamole security group
resource "aws_security_group_rule" "ingress_from_guacamole_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the operations security group
resource "aws_security_group_rule" "ingress_from_operations_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.operations.id
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
