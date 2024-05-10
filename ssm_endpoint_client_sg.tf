# Security group for instances that use the SSM VPC endpoints
resource "aws_security_group" "ssm_endpoint_client" {
  provider = aws.provisionassessment

  tags = {
    Name = "SSM endpoint client"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress via HTTPS to the SSM endpoint security group.
resource "aws_security_group_rule" "egress_from_ssm_endpoint_client_to_ssm_endpoint_via_https" {
  provider = aws.provisionassessment

  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ssm_endpoint_client.id
  source_security_group_id = aws_security_group.ssm_endpoint.id
  to_port                  = 443
  type                     = "egress"
}
