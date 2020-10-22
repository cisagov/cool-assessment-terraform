provider "aws" {
  region = "us-west-1"
}

#-------------------------------------------------------------------------------
# Data sources to get default VPC and its subnets.
#-------------------------------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

#-------------------------------------------------------------------------------
# Configure the example module.
#-------------------------------------------------------------------------------
module "example" {
  source = "../../"

  aws_region            = "us-west-1"
  aws_availability_zone = "b"
  subnet_id             = tolist(data.aws_subnet_ids.default.ids)[0]
}
