# ------------------------------------------------------------------------------
# DEPLOY THE EXAMPLE AMI FROM cisagov/skeleton-packer IN AWS
#
# Deploy the example AMI from cisagov/skeleton-packer in AWS.
# ------------------------------------------------------------------------------

# The AWS account ID being used
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# AUTOMATICALLY LOOK UP THE LATEST PRE-BUILT EXAMPLE AMI FROM
# cisagov/skeleton-packer.
#
# NOTE: This Terraform data source must return at least one AMI result
# or the apply will fail.
# ------------------------------------------------------------------------------

# The AMI from cisagov/skeleton-packer
data "aws_ami" "example" {
  filter {
    name = "name"
    values = [
      # Use the bastion AMI until the cisagov/skeleton-packer repo is
      # ready
      "cyhy-bastion-hvm-*-x86_64-ebs",
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
resource "aws_instance" "example" {
  ami               = data.aws_ami.example.id
  instance_type     = "t3.micro"
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  subnet_id         = var.subnet_id

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
