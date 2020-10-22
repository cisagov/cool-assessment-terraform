provider "aws" {
  # Our primary provider uses our terraform role
  region = var.aws_region
  assume_role {
    role_arn     = var.tf_role_arn
    session_name = "terraform-example"
  }
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
