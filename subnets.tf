#-------------------------------------------------------------------------------
# Create the public and private subnets for the assessment VPC.
#-------------------------------------------------------------------------------

# Public subnet of the VPC
resource "aws_subnet" "public" {
  provider = "aws.provisionassessment"

  vpc_id            = aws_vpc.assessment.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  depends_on = [aws_internet_gateway.assessment]

  tags = merge(
    var.tags,
    {
      "Name" = "Assessment Public"
    },
  )
}

# Private subnets of the VPC
resource "aws_subnet" "private" {
  provider = "aws.provisionassessment"

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
  provider = "aws.provisionassessment"

  vpc_id = aws_vpc.assessment.id
  tags   = var.tags
}

#-------------------------------------------------------------------------------
# Create NAT gateways for the private subnets.
# -------------------------------------------------------------------------------
resource "aws_eip" "nat_gw_eips" {
  provider = "aws.provisionassessment"

  for_each = toset(var.private_subnet_cidr_blocks)

  tags = var.tags
  vpc  = true
}

resource "aws_nat_gateway" "nat_gws" {
  provider = "aws.provisionassessment"

  for_each = toset(var.private_subnet_cidr_blocks)

  allocation_id = aws_eip.nat_gw_eips[each.value].id
  # Reminder: NAT gateways live in the public subnet
  subnet_id = aws_subnet.public.id
  tags      = var.tags
}
