#-------------------------------------------------------------------------------
# Create the assessment VPC.
#-------------------------------------------------------------------------------

# The VPC
resource "aws_vpc" "assessment" {
  provider = "aws.provisionassessment"

  # We can't perform this action until our policy is in place, so we
  # need this dependency.  Since the other resources in this file
  # directly or indirectly depend on the VPC, making the VPC depend on
  # this resource should make the other resources in this file depend
  # on it as well.
  depends_on = [
    aws_iam_role_policy_attachment.provisionassessment_policy_attachment
  ]

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags                 = var.tags
}

# Setup DHCP so we can resolve private DNS names
resource "aws_vpc_dhcp_options" "assessment" {
  provider = "aws.provisionassessment"

  domain_name         = var.private_domain
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = var.tags
}

# Associate the DHCP options above with the VPC
resource "aws_vpc_dhcp_options_association" "assessment" {
  provider = "aws.provisionassessment"

  dhcp_options_id = aws_vpc_dhcp_options.assessment.id
  vpc_id          = aws_vpc.assessment.id
}
