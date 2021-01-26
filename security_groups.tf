#-------------------------------------------------------------------------------
# Create the security groups for the assessment VPC.
#-------------------------------------------------------------------------------

# Security group for the desktop gateway instance in the private subnet
resource "aws_security_group" "desktop_gateway" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Desktop Gateway"
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

# Security group for the operations instances in the operations subnet
resource "aws_security_group" "operations" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Operations"
    },
  )
}

# Security group for the pentest portal instances in the operations subnet
resource "aws_security_group" "pentestportal" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Pentest Portal"
    },
  )
}

# Security group for the Debian desktop instances in the operations subnet
resource "aws_security_group" "debiandesktop" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Debian Desktop"
    },
  )
}
