#-------------------------------------------------------------------------------
# Create the security groups for the assessment VPC endpoints.
# -------------------------------------------------------------------------------

# Security group for the CloudWatch interface endpoints in the private
# subnet
resource "aws_security_group" "cloudwatch" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "CloudWatch endpoints"
    },
  )
}

# Security group for the SSM interface endpoint (and other endpoints
# required when using the SSM service) in the private subnet
resource "aws_security_group" "ssm" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "SSM endpoints"
    },
  )
}

# Security group for the STS interface endpoint in the private subnet
resource "aws_security_group" "sts" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "STS endpoint"
    },
  )
}
