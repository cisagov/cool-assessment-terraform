# Security group for instances that use the STS VPC endpoint
resource "aws_security_group" "sts_endpoint_client" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "STS endpoint client"
  }
}

# Allow egress via HTTPS from the STS endpoint security group.
resource "aws_security_group_rule" "egress_from_sts_endpoint_client_to_sts_endpoint_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.sts_endpoint_client.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sts_endpoint.id
  from_port                = 443
  to_port                  = 443
}
