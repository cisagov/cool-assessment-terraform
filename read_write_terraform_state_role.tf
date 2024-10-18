# ------------------------------------------------------------------------------
# Create the IAM policy and role that allows read-write access to the
# Terraform state for this project in the S3 bucket where Terraform
# remote state is stored.
# ------------------------------------------------------------------------------

module "read_write_terraform_state" {
  source = "github.com/cisagov/terraform-state-read-role-tf-module"

  providers = {
    aws = aws.provisionterraform
    # This provider is poorly named.  It is a provider that is allowed
    # to create IAM resources in the account(s) listed in account_ids.
    # In any event, this provider is not used here at all since the
    # module is configured with create_assume_role equal to false.  We
    # do have to put something there as a placeholder, though.
    aws.users = aws.provisionassessment
  }

  # The intent of this role is to allow selected IAM users to redeploy
  # this Terraform workspace.
  account_ids = [local.users_account_id]
  additional_read_only_states = {
    "cool-accounts/dynamic.tfstate"                    = { workspace = local.assessment_workspace_name }
    "cool-accounts/images.tfstate"                     = { workspace = local.workspace_type }
    "cool-accounts/master.tfstate"                     = { workspace = "production" }
    "cool-accounts/shared_services.tfstate"            = { workspace = local.workspace_type }
    "cool-accounts/terraform.tfstate"                  = { workspace = "production" }
    "cool-accounts/users.tfstate"                      = { workspace = "production" }
    "cool-dns-certboto/terraform.tfstate"              = { workspace = "production" }
    "cool-images-parameterstore/terraform.tfstate"     = { workspace = local.workspace_type }
    "cool-sharedservices-networking/terraform.tfstate" = { workspace = local.workspace_type }
  }
  # Note that the replace() function replaces "env0 (Staging)", for
  # example, with env0-Staging when it occurs at the end of the string
  additional_read_only_states_role_name = "${format(var.read_write_terraform_state_role_name, replace(var.assessment_account_name, "/ \\((?P<env_type>[[:alnum:]]*)\\)$/", "-$env_type"))}-AdditionalReadOnlyStates"
  create_assume_role                    = false
  lock_db_policy_name                   = format("TerraformLockDbPolicy-%s", replace(var.assessment_account_name, "/ \\((?P<env_type>[[:alnum:]]*)\\)$/", "-$env_type"))
  lock_db_table_arn                     = data.terraform_remote_state.terraform.outputs.state_lock_table.arn
  read_only                             = false
  # Note that the replace() function replaces "env0 (Staging)", for
  # example, with env0-Staging when it occurs at the end of the string
  role_name                   = format(var.read_write_terraform_state_role_name, replace(var.assessment_account_name, "/ \\((?P<env_type>[[:alnum:]]*)\\)$/", "-$env_type"))
  terraform_state_bucket_name = "cisa-cool-terraform-state"
  terraform_state_path        = "cool-assessment-terraform/terraform.tfstate"
  terraform_workspace         = local.assessment_workspace_name
}

# An IAM policy document that only allows users to assume the role
# created by the module above.
data "aws_iam_policy_document" "assume_read_write_role_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    effect    = "Allow"
    resources = [module.read_write_terraform_state.role.arn]
  }
}

# Attach the above policy to the selected users.
resource "aws_iam_user_policy" "attach_assume_read_write_role_doc" {
  for_each = toset(var.iam_users_allowed_to_self_deploy)
  provider = aws.provisionusers

  policy = data.aws_iam_policy_document.assume_read_write_role_doc.json
  user   = each.value
}
