#-------------------------------------------------------------------------------
# Create the security groups for the assessment VPC.
#-------------------------------------------------------------------------------

# Security group for the operations instances in the public subnet
resource "aws_security_group" "operations" {
  provider = "aws.provisionassessment"

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Operations"
    },
  )
}

# Security group for the desktop gateway instance in the private subnet
resource "aws_security_group" "desktop_gateway" {
  provider = "aws.provisionassessment"

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Desktop Gateway"
    },
  )
}
