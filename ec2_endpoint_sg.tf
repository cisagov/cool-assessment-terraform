# Security group for the EC2 interface endpoint in the private subnet
resource "aws_security_group" "ec2_endpoint" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "EC2 endpoint"
  }
}

# Allow ingress via HTTPS from the EC2 endpoint client security group
resource "aws_security_group_rule" "ingress_from_ec2_endpoint_client_to_ec2_endpoint_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ec2_endpoint.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_endpoint_client.id
  from_port                = 443
  to_port                  = 443
}
