# Security group for instances that use the S3 VPC endpoint
resource "aws_security_group" "s3_endpoint_client" {
  provider = aws.provisionassessment

  tags = {
    Name = "S3 endpoint client"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress via HTTPS to the S3 gateway endpoint.
resource "aws_security_group_rule" "egress_to_s3_endpoint_via_https" {
  provider = aws.provisionassessment

  from_port         = 443
  prefix_list_ids   = [aws_vpc_endpoint.s3.prefix_list_id]
  protocol          = "tcp"
  security_group_id = aws_security_group.s3_endpoint_client.id
  to_port           = 443
  type              = "egress"
}
