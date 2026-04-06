# ------------------------------------------------------------------------------
# Retrieves state data from a Terraform backend. This allows use of the
# root-level outputs of one or more Terraform configurations as input data
# for this configuration.
# ------------------------------------------------------------------------------

data "terraform_remote_state" "dns_certboto" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-dns-certboto/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}

data "terraform_remote_state" "dynamic_assessment" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/dynamic.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  # Note that this workspace is different from all the others.  For
  # the others we want production, staging, etc.  Here, though, we
  # want (for example) env0-production (for production), env0-staging,
  # etc.
  workspace = terraform.workspace
}

data "terraform_remote_state" "images" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/images.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}

data "terraform_remote_state" "images_assessment_images" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-images-assessment-images/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}

data "terraform_remote_state" "images_parameterstore" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-images-parameterstore/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}

data "terraform_remote_state" "master" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/master.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}

data "terraform_remote_state" "sharedservices" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/shared_services.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}

data "terraform_remote_state" "sharedservices_networking" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-sharedservices-networking/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}

data "terraform_remote_state" "terraform" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}

data "terraform_remote_state" "users" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/users.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = var.assessment_environment_name
}
