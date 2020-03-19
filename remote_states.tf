# ------------------------------------------------------------------------------
# Retrieves state data from a Terraform backend. This allows use of the
# root-level outputs of one or more Terraform configurations as input data
# for this configuration.
# ------------------------------------------------------------------------------

locals {
  # If this is a non-production account, for example, then there will
  # be a space followed by a string such as "Staging" to denote the
  # account type.  If it is a production account then there is no
  # space and no extra string.
  assessment_account_name_split = split(var.assessment_account_name, " ")
  production_workspace          = length(local.assessment_account_name_split) == 1
  # e.g. production, staging, etc.
  workspace_type = local.production_workspace ? "production" : lower(local.assessment_account_name_split[1])
  # e.g. env0 (for production), env0-staging, etc.
  workspace_name = local.production_workspace ? var.assessment_account_name : "${var.assessment_account_name}-${local.workspace_type}"
}

data "terraform_remote_state" "dns_certboto" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-dns-certboto/terraform.tfstate"
  }

  workspace = local.workspace_type
}

data "terraform_remote_state" "dynamic_assessment" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-accounts/dynamic.tfstate"
  }

  # Note that this workspace is different from all the others.  For
  # the others we want production, staging, etc.  Here, though, we
  # want (for example) env0, (for production), env0-staging, etc.
  workspace = local.workspace_name
}

data "terraform_remote_state" "images" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-accounts/images.tfstate"
  }

  workspace = local.workspace_type
}

data "terraform_remote_state" "images_parameterstore" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-images-parameterstore/terraform.tfstate"
  }

  workspace = local.workspace_type
}

data "terraform_remote_state" "master" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-accounts/master.tfstate"
  }

  workspace = local.workspace_type
}

data "terraform_remote_state" "sharedservices" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-accounts/shared_services.tfstate"
  }

  workspace = local.workspace_type
}

data "terraform_remote_state" "sharedservices_networking" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-sharedservices-networking/terraform.tfstate"
  }

  workspace = local.workspace_type
}
