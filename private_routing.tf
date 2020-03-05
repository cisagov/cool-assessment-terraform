#-------------------------------------------------------------------------------
# Note that all these resources depend on the VPC, the NAT GWs, or
# both, and hence on the
# aws_iam_role_policy_attachment.provisionassessment_policy_attachment
# resource.
# -------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Set up routing for the private subnets.
#
# The public subnets will use the default routing table in the VPC, as
# defined in public_routing.tf.
# -------------------------------------------------------------------------------

# Each private subnet gets its own routing table, since each subnet
# uses its own NAT gateway.
resource "aws_route_table" "private_route_tables" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  tags   = var.tags
  vpc_id = aws_vpc.assessment.id
}

# # Route all non-local COOL (outside this VPC but inside the COOL)
# # traffic through the transit gateway.
# resource "aws_route" "cool_routes" {
#   for_each = toset(var.private_subnet_cidr_blocks)
#
#   route_table_id         = aws_route_table.private_route_tables[each.value].id
#   destination_cidr_block = var.cool_cidr_block
#   transit_gateway_id     = local.transit_gateway_id
# }

# Route all external (outside this VPC and outside the COOL) traffic
# through the NAT gateways
resource "aws_route" "external_routes" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  route_table_id         = aws_route_table.private_route_tables[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gws[each.value].id
}

# Associate the routing tables with the subnets
resource "aws_route_table_association" "private_route_table_associations" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private_route_tables[each.value].id
}
