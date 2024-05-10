#-------------------------------------------------------------------------------
# Create the operations and private subnets for the assessment VPC.
#-------------------------------------------------------------------------------

# Operations subnet of the VPC
resource "aws_subnet" "operations" {
  provider   = aws.provisionassessment
  depends_on = [aws_internet_gateway.assessment]

  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  cidr_block        = var.operations_subnet_cidr_block
  tags = {
    Name = "Assessment Operations"
  }
  vpc_id = aws_vpc.assessment.id
}

# Private subnets of the VPC
resource "aws_subnet" "private" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  cidr_block        = each.key
  tags = {
    Name = format("Assessment Private - %s", each.key)
  }
  vpc_id = aws_vpc.assessment.id
}

# The internet gateway for the VPC
resource "aws_internet_gateway" "assessment" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id
}

#-------------------------------------------------------------------------------
# Create a NAT gateway for the private subnets.
# -------------------------------------------------------------------------------
resource "aws_eip" "nat_gw" {
  provider = aws.provisionassessment

  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  provider = aws.provisionassessment

  allocation_id = aws_eip.nat_gw.id
  # Reminder: The NAT gateway lives in the operations subnet
  subnet_id = aws_subnet.operations.id
}
