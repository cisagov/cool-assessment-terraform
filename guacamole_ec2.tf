# The Guacamole AMI
data "aws_ami" "guacamole" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "guacamole-hvm-*-x86_64-ebs"
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

# The Guacamole EC2 instance
resource "aws_instance" "guacamole" {
  provider = aws.provisionassessment

  ami                  = data.aws_ami.guacamole.id
  availability_zone    = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile = aws_iam_instance_profile.guacamole.name
  instance_type        = "t3.medium"
  subnet_id            = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  user_data_base64 = data.cloudinit_config.guacamole_cloud_init_tasks.rendered

  vpc_security_group_ids = [
    aws_security_group.desktop_gateway.id,
  ]

  tags        = merge(var.tags, map("Name", "Guacamole"))
  volume_tags = merge(var.tags, map("Name", "Guacamole"))
}
