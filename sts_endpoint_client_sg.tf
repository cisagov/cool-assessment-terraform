# Security group for instances that use the STS VPC endpoint
resource "aws_security_group" "sts_endpoint_client" {
  provider = aws.provisionassessment

  tags = {
    Name = "STS endpoint client"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress via HTTPS from the STS endpoint security group.
resource "aws_security_group_rule" "egress_from_sts_endpoint_client_to_sts_endpoint_via_https" {
  provider = aws.provisionassessment

  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sts_endpoint_client.id
  source_security_group_id = aws_security_group.sts_endpoint.id
  to_port                  = 443
  type                     = "egress"
}
