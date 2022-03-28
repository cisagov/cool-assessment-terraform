# Security group for all instances.  This security group allows access
# to the VPC endpoint resources necessary for the AWS CloudWatch agent
# and the AWS SSM agent.
resource "aws_security_group" "cloudwatch_and_ssm_agent" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "AWS CloudWatch and SSM agents"
  }
}

# Allow egress via HTTPS to any SSM interface endpoints
#
# For: All instances require access to SSM for SSH access via the AWS
# control plane.
resource "aws_security_group_rule" "agent_egress_to_ssm_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch_and_ssm_agent.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ssm_endpoint.id
  from_port                = 443
  to_port                  = 443
}

# Allow egress via HTTPS to any Cloudwatch interface endpoints
#
# For: All instances requires access to CloudWatch for CloudWatch log
# forwarding via the CloudWatch agent.
resource "aws_security_group_rule" "agent_egress_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.cloudwatch_and_ssm_agent.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cloudwatch.id
  from_port                = 443
  to_port                  = 443
}
