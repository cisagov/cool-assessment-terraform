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

  tags = merge(
    var.tags,
    {
      "Name" = "Assessment Operations"
    },
  )
}

# Private subnets of the VPC
resource "aws_subnet" "private" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.assessment.id
  cidr_block        = each.key
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  tags = merge(
    var.tags,
    {
      "Name" = format("Assessment Private - %s", each.key)
    },
  )
}

# The internet gateway for the VPC
resource "aws_internet_gateway" "assessment" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id
  tags   = var.tags
}

#-------------------------------------------------------------------------------
# Create a NAT gateway for the private subnets.
# -------------------------------------------------------------------------------
resource "aws_eip" "nat_gw" {
  provider = aws.provisionassessment

  tags = var.tags
  vpc  = true
}

resource "aws_nat_gateway" "nat_gw" {
  provider = aws.provisionassessment

  allocation_id = aws_eip.nat_gw.id
  # Reminder: The NAT gateway lives in the operations subnet
  subnet_id = aws_subnet.operations.id
  tags      = var.tags
}
