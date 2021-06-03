provider "aws" {
  # Our primary provider uses our terraform role
  assume_role {
    role_arn     = var.tf_role_arn
    session_name = "terraform-example"
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}

#-------------------------------------------------------------------------------
# Configure the example module.
#-------------------------------------------------------------------------------
module "example" {
  source = "../../"
  providers = {
    aws = aws
  }

  ami_owner_account_id  = var.ami_owner_account_id
  aws_availability_zone = var.aws_availability_zone
  aws_region            = var.aws_region
  subnet_id             = aws_subnet.example.id
}
