# Security group for the STS interface endpoint in the private subnet
resource "aws_security_group" "sts_endpoint" {
  provider = aws.provisionassessment

  tags = {
    Name = "STS endpoint"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow ingress via HTTPS from the STS endpoint client security group.
resource "aws_security_group_rule" "ingress_from_sts_endpoint_client_to_sts_endpoint_via_https" {
  provider = aws.provisionassessment

  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sts_endpoint.id
  source_security_group_id = aws_security_group.sts_endpoint_client.id
  to_port                  = 443
  type                     = "ingress"
}
