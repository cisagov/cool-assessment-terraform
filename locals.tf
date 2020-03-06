# ------------------------------------------------------------------------------
# Retrieve the effective Account ID, User ID, and ARN in which Terraform is
# authorized.  This is used to calculate the session names for assumed roles.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# Retrieve the information for all accouts in the organization.  This is used
# to lookup the Users account ID for use in the assume role policy.
# ------------------------------------------------------------------------------
data "aws_organizations_organization" "cool" {
  provider = aws.organizationsreadonly
}

# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  # Extract the user name of the current caller for use
  # as assume role session names.
  caller_user_name = split("/", data.aws_caller_identity.current.arn)[1]

  cool_shared_services_cidr_block = data.terraform_remote_state.sharedservices_networking.outputs.vpc.cidr_block

  # Helpful lists for defining ACL and security group rules
  ingress_and_egress = [
    "ingress",
    "egress",
  ]
  tcp_and_udp = [
    "tcp",
    "udp",
  ]

  # The ID of the Transit Gateway in the Shared Services account
  transit_gateway_id = data.terraform_remote_state.sharedservices_networking.outputs.transit_gateway.id

  # Find the new Users account by name and email.
  users_account_id = [
    for x in data.aws_organizations_organization.cool.accounts :
    x.id if x.name == "Users" && length(regexall("2020", x.email)) > 0
  ][0]
}
