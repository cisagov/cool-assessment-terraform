# ------------------------------------------------------------------------------
# Create the IAM policy and role that allows read-only access to the Terraform
# state for this project in the S3 bucket where Terraform remote state is
# stored.
# ------------------------------------------------------------------------------

module "read_terraform_state" {
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

  account_ids = [local.assessment_account_id]
  # We don't want to create the assume role, since in this case the
  # Terraformer instance role is given permission to assume this role
  # directly in terraformer_iam.tf.
  create_assume_role = false
  # Note that the replace() function replaces "env0 (Staging)", for
  # example, with env0-Staging when it occurs at the end of the string
  role_name                   = format(var.read_terraform_state_role_name, replace(var.assessment_account_name, "/ \\((?P<env_type>[[:alnum:]]*)\\)$/", "-$env_type"))
  terraform_state_bucket_name = "cisa-cool-terraform-state"
  terraform_state_path        = "cool-assessment-terraform/terraform.tfstate"
  terraform_workspace         = local.assessment_workspace_name
}
