# Security group for instances that use the S3 VPC endpoint
resource "aws_security_group" "s3_endpoint_client" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "S3 endpoint client"
  }
}

# Allow egress via HTTPS to the S3 gateway endpoint.
resource "aws_security_group_rule" "egress_to_s3_endpoint_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.s3_endpoint_client.id
  type              = "egress"
  protocol          = "tcp"
  prefix_list_ids   = [aws_vpc_endpoint.s3.prefix_list_id]
  from_port         = 443
  to_port           = 443
}
