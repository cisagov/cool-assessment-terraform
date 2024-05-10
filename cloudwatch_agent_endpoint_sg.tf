# Security group for the interface endpoints used by the CloudWatch
# agent in the private subnet
resource "aws_security_group" "cloudwatch_agent_endpoint" {
  provider = aws.provisionassessment

  tags = {
    Name = "CloudWatch agent endpoints"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow ingress via HTTPS from the CloudWatch agent endpoint client
# security group.
resource "aws_security_group_rule" "ingress_from_cloudwatch_agent_endpoint_client_to_cloudwatch_agent_endpoint_via_https" {
  provider = aws.provisionassessment

  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cloudwatch_agent_endpoint.id
  source_security_group_id = aws_security_group.cloudwatch_agent_endpoint_client.id
  to_port                  = 443
  type                     = "ingress"
}
