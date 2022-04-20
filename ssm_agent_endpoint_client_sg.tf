# Security group for instances that use the SSM agent
resource "aws_security_group" "ssm_agent_endpoint_client" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "SSM agent endpoint client"
  }
}

# Allow egress via HTTPS to the SSM agent endpoint security group.
resource "aws_security_group_rule" "egress_from_ssm_agent_endpoint_client_to_ssm_agent_endpoint_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.ssm_agent_endpoint_client.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ssm_agent_endpoint.id
  from_port                = 443
  to_port                  = 443
}
