# Security group for instances that use the SSM VPC endpoints
resource "aws_security_group" "ssm_endpoint_client" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "SSM endpoint client"
  }
}

# Allow egress via HTTPS to the SSM endpoint security group.
resource "aws_security_group_rule" "egress_from_ssm_endpoint_client_to_ssm_endpoint_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ssm_endpoint_client.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ssm_endpoint.id
  from_port                = 443
  to_port                  = 443
}
