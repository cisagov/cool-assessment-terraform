#-------------------------------------------------------------------------------
# Create the VPC endpoints.
#-------------------------------------------------------------------------------

#
# VPC interface endpoints
#

# STS interface endpoint
resource "aws_vpc_endpoint" "sts" {
  provider = aws.provisionassessment

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.sts.id,
  ]
  service_name      = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.assessment.id
}

# SSM interface endpoints
resource "aws_vpc_endpoint" "ssm" {
  provider = aws.provisionassessment

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.ssm.id,
  ]
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.assessment.id
}
resource "aws_vpc_endpoint" "ec2" {
  provider = aws.provisionassessment

  private_dns_enabled = true
  security_group_ids = [
    # The CloudWatch agent reads a few pieces of data from the ec2
    # endpoint.  You can see this by inspecting the AWS-provided
    # CloudWatchAgentServerPolicyIAM policy.
    aws_security_group.cloudwatch.id,
    aws_security_group.ec2_endpoint.id,
    aws_security_group.ssm.id,
  ]
  service_name      = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.assessment.id
}
resource "aws_vpc_endpoint" "ec2messages" {
  provider = aws.provisionassessment

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.ssm.id,
  ]
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.assessment.id
}
resource "aws_vpc_endpoint" "kms" {
  provider = aws.provisionassessment

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.ssm.id,
  ]
  service_name      = "com.amazonaws.${var.aws_region}.kms"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.assessment.id
}
resource "aws_vpc_endpoint" "ssmmessages" {
  provider = aws.provisionassessment

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.ssm.id,
  ]
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.assessment.id
}

# CloudWatch interface endpoints
resource "aws_vpc_endpoint" "logs" {
  provider = aws.provisionassessment

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.cloudwatch.id,
  ]
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.assessment.id
}
resource "aws_vpc_endpoint" "monitoring" {
  provider = aws.provisionassessment

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.cloudwatch.id,
  ]
  service_name      = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.assessment.id
}

# Associate the STS interface endpoint with the private subnets
resource "aws_vpc_endpoint_subnet_association" "sts" {
  provider = aws.provisionassessment

  # Normally we would use a for_each here, but the private subnets are
  # _all in the same AZ_ in this case.  Why even have multiple subnets
  # if you're not going to spread them around?  Harumph!
  # for_each = toset(var.private_subnet_cidr_blocks)

  # subnet_id       = aws_subnet.private[each.value].id
  subnet_id       = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  vpc_endpoint_id = aws_vpc_endpoint.sts.id
}

# Associate the SSM interface endpoints with the private subnets
#
# Note that SSM requires several other endpoints to function properly.
# See here for more details:
# https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html#sysman-setting-up-vpc-create
resource "aws_vpc_endpoint_subnet_association" "ssm" {
  provider = aws.provisionassessment

  # Normally we would use a for_each here, but the private subnets are
  # _all in the same AZ_ in this case.  Why even have multiple subnets
  # if you're not going to spread them around?  Harumph!
  # for_each = toset(var.private_subnet_cidr_blocks)

  # subnet_id       = aws_subnet.private[each.value].id
  subnet_id       = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  vpc_endpoint_id = aws_vpc_endpoint.ssm.id
}
resource "aws_vpc_endpoint_subnet_association" "ec2" {
  provider = aws.provisionassessment

  # Normally we would use a for_each here, but the private subnets are
  # _all in the same AZ_ in this case.  Why even have multiple subnets
  # if you're not going to spread them around?  Harumph!
  # for_each = toset(var.private_subnet_cidr_blocks)

  # subnet_id       = aws_subnet.private[each.value].id
  subnet_id       = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  vpc_endpoint_id = aws_vpc_endpoint.ec2.id
}
resource "aws_vpc_endpoint_subnet_association" "ec2messages" {
  provider = aws.provisionassessment

  # Normally we would use a for_each here, but the private subnets are
  # _all in the same AZ_ in this case.  Why even have multiple subnets
  # if you're not going to spread them around?  Harumph!
  # for_each = toset(var.private_subnet_cidr_blocks)

  # subnet_id       = aws_subnet.private[each.value].id
  subnet_id       = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  vpc_endpoint_id = aws_vpc_endpoint.ec2messages.id
}
resource "aws_vpc_endpoint_subnet_association" "kms" {
  provider = aws.provisionassessment

  # Normally we would use a for_each here, but the private subnets are
  # _all in the same AZ_ in this case.  Why even have multiple subnets
  # if you're not going to spread them around?  Harumph!
  # for_each = toset(var.private_subnet_cidr_blocks)

  # subnet_id       = aws_subnet.private[each.value].id
  subnet_id       = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  vpc_endpoint_id = aws_vpc_endpoint.kms.id
}
resource "aws_vpc_endpoint_subnet_association" "ssmmessages" {
  provider = aws.provisionassessment

  # Normally we would use a for_each here, but the private subnets are
  # _all in the same AZ_ in this case.  Why even have multiple subnets
  # if you're not going to spread them around?  Harumph!
  # for_each = toset(var.private_subnet_cidr_blocks)

  # subnet_id       = aws_subnet.private[each.value].id
  subnet_id       = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  vpc_endpoint_id = aws_vpc_endpoint.ssmmessages.id
}

# Associate the CloudWatch interface endpoints with the private
# subnets
resource "aws_vpc_endpoint_subnet_association" "logs" {
  provider = aws.provisionassessment

  # Normally we would use a for_each here, but the private subnets are
  # _all in the same AZ_ in this case.  Why even have multiple subnets
  # if you're not going to spread them around?  Harumph!
  # for_each = toset(var.private_subnet_cidr_blocks)

  # subnet_id       = aws_subnet.private[each.value].id
  subnet_id       = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  vpc_endpoint_id = aws_vpc_endpoint.logs.id
}
resource "aws_vpc_endpoint_subnet_association" "monitoring" {
  provider = aws.provisionassessment

  # Normally we would use a for_each here, but the private subnets are
  # _all in the same AZ_ in this case.  Why even have multiple subnets
  # if you're not going to spread them around?  Harumph!
  # for_each = toset(var.private_subnet_cidr_blocks)

  # subnet_id       = aws_subnet.private[each.value].id
  subnet_id       = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  vpc_endpoint_id = aws_vpc_endpoint.monitoring.id
}

#
# VPC gateway endpoints
#

# S3 gateway endpoint
resource "aws_vpc_endpoint" "s3" {
  provider = aws.provisionassessment

  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.assessment.id
}

# DynamoDB gateway endpoint
resource "aws_vpc_endpoint" "dynamodb" {
  provider = aws.provisionassessment

  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.assessment.id
}
