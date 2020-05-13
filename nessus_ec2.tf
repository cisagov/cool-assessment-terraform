# NOTE: Most of the Nessus-related Terraform in this repo can be replaced
# with a module (e.g. "nessus-tf-module") AFTER Terraform modules support
# the use of "count" - see https://github.com/cisagov/cool-system/issues/32
# for details.

# The Nessus AMI
data "aws_ami" "nessus" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "nessus-hvm-*-x86_64-ebs"
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

  owners      = [local.images_account_id]
  most_recent = true
}

# The Nessus EC2 instance
resource "aws_instance" "nessus" {
  count    = lookup(var.operations_instance_counts, "nessus", 0)
  provider = aws.provisionassessment

  ami                         = data.aws_ami.nessus.id
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile        = aws_iam_instance_profile.nessus[0].name
  instance_type               = "m5.large"
  subnet_id                   = aws_subnet.operations.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  user_data_base64 = data.template_cloudinit_config.nessus_cloud_init_tasks[count.index].rendered

  vpc_security_group_ids = [
    aws_security_group.operations.id
  ]

  tags        = merge(var.tags, map("Name", format("Nessus%d", count.index)))
  volume_tags = merge(var.tags, map("Name", format("Nessus%d", count.index)))
}
