# Security group for Terraformer instances
resource "aws_security_group" "terraformer" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "Terraformer"
  }
}

# Allow egress anywhere via ssh
#
# For: Terraformer instances must be able to configure redirectors and
# operations instances via Ansible.
resource "aws_security_group_rule" "terraformer_egress_anywhere_via_ssh" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.terraformer.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
}

# Allow egress anywhere via HTTP
#
# For: Terraformer instances must be able to install packages.
resource "aws_security_group_rule" "terraformer_egress_anywhere_via_http" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.terraformer.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
}

# Allow egress anywhere via HTTPS
#
# For: Terraformer instances must be able to terraform init.
resource "aws_security_group_rule" "terraformer_egress_anywhere_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.terraformer.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
}

# Allow egress via HTTPS to any STS interface endpoint
#
# For: Terraformer instances assume a role via STS.  This role allows
# Terraformer instances to create/destroy/modify AWS resources.
resource "aws_security_group_rule" "terraformer_egress_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.terraformer.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sts.id
  from_port                = 443
  to_port                  = 443
}

# Allow egress via HTTPS to the S3 gateway endpoint
#
# For: Terraformer instances require access to S3 in order to read and
# write their remote state.
resource "aws_security_group_rule" "terraformer_egress_to_s3_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.terraformer.id
  type              = "egress"
  protocol          = "tcp"
  prefix_list_ids   = [aws_vpc_endpoint.s3.prefix_list_id]
  from_port         = 443
  to_port           = 443
}

# Allow egress via HTTPS to the DynamoDB gateway endpoint
#
# For: Terraformer instances require access to DynamoDB in order to
# acquire a lock before writing their remote state.
resource "aws_security_group_rule" "terraformer_egress_to_dynamodb_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.terraformer.id
  type              = "egress"
  protocol          = "tcp"
  prefix_list_ids   = [aws_vpc_endpoint.dynamodb.prefix_list_id]
  from_port         = 443
  to_port           = 443
}

# Allow egress anywhere via port 5986 (Windows Remote Manager).
#
# For: Terraformer instances must be able to configure Windows-based
# operations instances via Ansible.
resource "aws_security_group_rule" "terraformer_egress_to_operations_via_winrm" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.terraformer.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = [aws_subnet.operations.cidr_block]
  from_port         = 5986
  to_port           = 5986
}
