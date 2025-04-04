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

  # Determine if we are using the legacy or current account naming scheme.
  #
  # Legacy account names look like "ACCOUNT_NAME (ACCOUNT_TYPE)", e.g.:
  # - "Images (Production)", "Images (Staging)"
  # - "Shared Services (Production)", "Shared Services (Staging)"
  # - "env0 (Production)", "env0 (Staging)", "env1 (Production)", "env1 (Staging)", etc.
  #
  # Current account names look like "ACCOUNT_NAME", e.g.:
  # - "Images"
  # - "Shared Services"
  # - "env0", "env1", etc.
  #
  # Until all legacy environments have been migrated to this current naming
  # scheme, we must check account names via the regex below to determine whether
  # we are using the legacy naming scheme or not.
  #
  # Check the assessment (env*) account name to determine the naming scheme
  account_naming_scheme = length(regexall("\\(([^()]*)\\)", local.assessment_account_name)) == 1 ? "legacy" : "current"

  # Determine the ID of the Images account
  images_account_name_regex = local.account_naming_scheme == "legacy" ? format("^Images \\(%s\\)$", trim(split("(", local.assessment_account_name)[1], ")")) : "^Images$"

  images_account_id = [
    for account in data.aws_organizations_organization.cool.non_master_accounts :
    account.id
    if length(regexall(local.images_account_name_regex, account.name)) > 0
  ][0]
}
