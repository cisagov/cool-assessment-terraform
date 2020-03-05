#-------------------------------------------------------------------------------
# Create the network ACLs for the public and private subnets
# in the assessment VPC.
#-------------------------------------------------------------------------------

# ACL for the public subnet of the VPC
resource "aws_network_acl" "public" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id
  subnet_ids = [
    aws_subnet.public.id,
  ]

  tags = merge(
    var.tags,
    {
      "Name" = "Assessment Public"
    },
  )
}

# ACLs for the private subnet of the VPC
resource "aws_network_acl" "private" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  vpc_id = aws_vpc.assessment.id
  subnet_ids = [
    aws_subnet.private[each.key].id,
  ]

  tags = merge(
    var.tags,
    {
      "Name" = format("Assessment Private - %s", each.key)
    },
  )
}
