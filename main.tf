# ------------------------------------------------------------------------------
# DEPLOY THE EXAMPLE AMI FROM cisagov/skeleton-packer IN AWS
#
# Deploy the example AMI from cisagov/skeleton-packer in AWS.
# ------------------------------------------------------------------------------

# The AWS account ID being used
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# AUTOMATICALLY LOOK UP THE LATEST PRE-BUILT AMI
#
# NOTE: This Terraform data source must return at least one AMI result
# or the apply will fail.
# ------------------------------------------------------------------------------

# The AMI from cisagov/skeleton-example-packer
data "aws_ami" "example" {
  filter {
    name = "name"
    values = [
      "openvpn-hvm-*-x86_64-ebs",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners      = [data.aws_caller_identity.current.account_id] # This is us
  most_recent = true
}

# The example EC2 instance
resource "aws_instance" "bod_bastion" {
  ami           = data.aws_ami.bastion.id
  instance_type = "t3.micro"

  tags = merge(
    var.tags,
    {
      "Name" = "Example"
    },
  )
  volume_tags = merge(
    var.tags,
    {
      "Name" = "Example"
    },
  )
}
