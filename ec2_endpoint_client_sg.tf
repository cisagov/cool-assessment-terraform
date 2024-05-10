# Security group for instances that use the EC2 VPC endpoint
resource "aws_security_group" "ec2_endpoint_client" {
  provider = aws.provisionassessment

  tags = {
    Name = "EC2 endpoint client"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress via HTTPS to the EC2 endpoint security group.
resource "aws_security_group_rule" "egress_from_ec2_endpoint_client_to_ec2_endpoint_via_https" {
  provider = aws.provisionassessment

  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_endpoint_client.id
  source_security_group_id = aws_security_group.ec2_endpoint.id
  to_port                  = 443
  type                     = "egress"
}
