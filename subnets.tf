#-------------------------------------------------------------------------------
# Create the operations and private subnets for the assessment VPC.
#-------------------------------------------------------------------------------

# Operations subnet of the VPC
resource "aws_subnet" "operations" {
  provider = aws.provisionassessment

  vpc_id            = aws_vpc.assessment.id
  cidr_block        = var.operations_subnet_cidr_block
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  depends_on = [aws_internet_gateway.assessment]

  tags = {
    Name = "Assessment Operations"
  }
}

# Private subnets of the VPC
resource "aws_subnet" "private" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.assessment.id
  cidr_block        = each.key
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  tags = {
    Name = format("Assessment Private - %s", each.key)
  }
}

# The internet gateway for the VPC
resource "aws_internet_gateway" "assessment" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id
}
