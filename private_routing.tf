#-------------------------------------------------------------------------------
# Note that all these resources depend on the VPC, the NAT GWs, or
# both, and hence on the
# aws_iam_role_policy_attachment.provisionassessment_policy_attachment
# resource.
# -------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Set up routing for the private subnets.
#
# The operations subnets will use the default routing table in the VPC, as
# defined in operations_routing.tf.
# -------------------------------------------------------------------------------

# The private subnets can all share a single routing table.  Normally
# we would assign each subnet its own NAT gateway, which would require
# separate routing tables, but in this case we do not create any NAT
# gateways since nothing in the private subnets requires access to the
# internet outside the VPC.
resource "aws_route_table" "private_route_table" {
  provider = aws.provisionassessment

  tags   = var.tags
  vpc_id = aws_vpc.assessment.id
}

# Route all COOL Shared Services traffic through the transit gateway.
resource "aws_route" "cool_private" {
  provider = aws.provisionassessment

  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = local.cool_shared_services_cidr_block
  transit_gateway_id     = local.transit_gateway_id
}

# Associate the S3 gateway endpoint with the route table
resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  provider = aws.provisionassessment

  route_table_id  = aws_route_table.private_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

# Associate the routing table with the subnets
resource "aws_route_table_association" "private_route_table_associations" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private_route_table.id
}
