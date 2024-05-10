# Security group for instances that use the DynamoDB VPC endpoint.
resource "aws_security_group" "dynamodb_endpoint_client" {
  provider = aws.provisionassessment

  tags = {
    Name = "DynamoDB endpoint client"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress via HTTPS to the DynamoDB gateway endpoint.
resource "aws_security_group_rule" "egress_to_dynamodb_endpoint_via_https" {
  provider = aws.provisionassessment

  from_port         = 443
  prefix_list_ids   = [aws_vpc_endpoint.dynamodb.prefix_list_id]
  protocol          = "tcp"
  security_group_id = aws_security_group.dynamodb_endpoint_client.id
  to_port           = 443
  type              = "egress"
}
