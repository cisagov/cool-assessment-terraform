# ------------------------------------------------------------------------------
# Retrieve the caller identity for the current assessment in order to
# get the associated Account ID.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "assessment" {
}

# ------------------------------------------------------------------------------
# Retrieve the information for all accouts in the organization.  This is used
# to lookup the Users account ID for use in the assume role policy.
# ------------------------------------------------------------------------------
data "aws_organizations_organization" "cool" {
  provider = aws.read_organization_information
}

# ------------------------------------------------------------------------------
# Retrieve the default tags for the assessment provider.  These are
# used to create volume tags for EC2 instances, since volume_tags does
# not yet inherit the default tags from the provider.  See
# hashicorp/terraform-provider-aws#19188 for more details.
# ------------------------------------------------------------------------------
data "aws_default_tags" "assessment" {
}

# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  # The account ID for this assessment
  assessment_account_id = data.aws_caller_identity.assessment.account_id

  # Look up assessment account name from AWS organizations provider
  assessment_account_name = [
    for account in data.aws_organizations_organization.cool.non_master_accounts :
    account.name
    if account.id == local.assessment_account_id
  ][0]

  # Find the "Images" account ID by name.
  images_account_id = [
    for account in data.aws_organizations_organization.cool.non_master_accounts :
    account.id if account.name == "Images"
  ][0]
}
