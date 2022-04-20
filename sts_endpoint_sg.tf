# Security group for the STS interface endpoint in the private subnet
resource "aws_security_group" "sts_endpoint" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "STS endpoint"
  }
}

# Allow ingress via HTTPS from the STS endpoint client security group.
resource "aws_security_group_rule" "ingress_from_sts_endpoint_client_to_sts_endpoint_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.sts_endpoint.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sts_endpoint_client.id
  from_port                = 443
  to_port                  = 443
}
