#-------------------------------------------------------------------------------
# Create the network ACLs for the operations and private subnets
# in the assessment VPC.
#-------------------------------------------------------------------------------

# ACL for the operations subnet of the VPC
resource "aws_network_acl" "operations" {
  provider = aws.provisionassessment

  subnet_ids = [
    aws_subnet.operations.id,
  ]
  tags = {
    "Name" = "Assessment Operations"
  }
  vpc_id = aws_vpc.assessment.id
}

# ACLs for the private subnets of the VPC
resource "aws_network_acl" "private" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  subnet_ids = [
    aws_subnet.private[each.key].id,
  ]
  tags = {
    "Name" = format("Assessment Private - %s", each.key)
  }
  vpc_id = aws_vpc.assessment.id
}
