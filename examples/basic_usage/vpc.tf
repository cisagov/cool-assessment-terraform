#-------------------------------------------------------------------------------
# Create a VPC
#-------------------------------------------------------------------------------

resource "aws_vpc" "example" {
  cidr_block           = "10.230.0.0/24"
  enable_dns_hostnames = true
  tags                 = { "Name" : "Example" }
}

#-------------------------------------------------------------------------------
# Create a subnet
#-------------------------------------------------------------------------------

resource "aws_subnet" "example" {
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  cidr_block        = "10.230.0.0/28"
  tags              = { "Name" : "Example" }
  vpc_id            = aws_vpc.example.id
}
