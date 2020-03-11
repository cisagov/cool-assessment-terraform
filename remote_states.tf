# ------------------------------------------------------------------------------
# Retrieves state data from a Terraform backend. This allows use of the
# root-level outputs of one or more Terraform configurations as input data
# for this configuration.
# ------------------------------------------------------------------------------
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

  workspace = "production"
}

data "terraform_remote_state" "dynamic_assessment" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-accounts/${var.assessment_account_name}.tfstate"
  }

  workspace = var.assessment_account_name
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

  workspace = "production"
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

  workspace = "production"
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

  workspace = "production"
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

  workspace = "production"
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

  workspace = "production"
}
