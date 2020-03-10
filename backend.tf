terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    # Locally change DYNAMIC_ACCOUNT_NAME below
    # to the name of the new environment
    # TODO: https://github.com/cisagov/cool-accounts/issues/34
    key = "cool-assessment-terraform/DYNAMIC_ACCOUNT_NAME.tfstate"
  }
}
