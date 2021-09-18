# This is the "default" provider that is used assume the roles in the other
# providers.  It uses the credentials of the caller.  It is also used to
# assume the roles required to access remote state in the Terraform backend.

provider "aws" {
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}

provider "aws" {
  alias = "dns_sharedservices"
  assume_role {
    role_arn     = data.terraform_remote_state.sharedservices.outputs.provisionaccount_role.arn
    session_name = local.caller_user_name
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region # route53 is global, but still required by Terraform
}

# The provider used to create roles that can read certificates from an S3 bucket
provider "aws" {
  alias = "provisioncertreadrole"
  assume_role {
    role_arn     = data.terraform_remote_state.dns_certboto.outputs.provisioncertificatereadroles_role.arn
    session_name = local.caller_user_name
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}

# The provider used to create resources inside the AWS account used
# for this assessment
provider "aws" {
  alias = "provisionassessment"
  assume_role {
    role_arn     = data.terraform_remote_state.dynamic_assessment.outputs.provisionaccount_role.arn
    session_name = local.caller_user_name
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}

# The provider used to create roles that can read parameter data
# from an SSM Parameter Store
provider "aws" {
  alias = "provisionparameterstorereadrole"
  assume_role {
    role_arn     = data.terraform_remote_state.images_parameterstore.outputs.provisionparameterstorereadroles_role.arn
    session_name = local.caller_user_name
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}

# The provider used to lookup account IDs.  See locals.
provider "aws" {
  alias = "organizationsreadonly"
  assume_role {
    role_arn     = data.terraform_remote_state.master.outputs.organizationsreadonly_role.arn
    session_name = local.caller_user_name
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}

# The provider used to manipulate Transit Gateway route tables inside
# the Shared Services account
provider "aws" {
  alias = "provisionsharedservices"
  assume_role {
    role_arn     = data.terraform_remote_state.sharedservices.outputs.provisionaccount_role.arn
    session_name = local.caller_user_name
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}

# This provider is required by the read_terraform_state module in
# read_terraform_state_role.tf in order to create the read-only role
# for this Terraform root module's Terraform state.
provider "aws" {
  alias = "provisionterraform"
  assume_role {
    role_arn     = data.terraform_remote_state.terraform.outputs.provisionaccount_role.arn
    session_name = local.caller_user_name
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}
