# Security group for the EC2 interface endpoint in the private subnet
resource "aws_security_group" "ec2" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "EC2 endpoint"
  }
}

# Allow ingress via HTTPS from the Guacamole security group
resource "aws_security_group_rule" "ingress_from_guacamole_to_ec2_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ec2.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 443
  to_port                  = 443
}
