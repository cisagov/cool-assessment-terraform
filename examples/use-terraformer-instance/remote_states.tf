# ------------------------------------------------------------------------------
# Retrieves state data from a Terraform backend. This allows use of
# the root-level outputs of one or more Terraform configurations as
# input data for this configuration.
# ------------------------------------------------------------------------------

data "terraform_remote_state" "cool_assessment_terraform" {
  backend = "s3"
  config = {
    bucket  = var.terraform_state_bucket
    encrypt = true
    key     = "cool-assessment-terraform/terraform.tfstate"
    profile = "read_cool_assessment_terraform_state"
    region  = "us-east-1"
  }
  workspace = terraform.workspace
}
