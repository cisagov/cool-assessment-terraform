# The Kali AMI
data "aws_ami" "kali" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "kali-hvm-*-x86_64-ebs"
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

# The Kali EC2 instance
resource "aws_instance" "kali" {
  count    = var.operations_instance_counts["kali"]
  provider = aws.provisionassessment

  ami                         = data.aws_ami.kali.id
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile        = aws_iam_instance_profile.kali.name
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.operations.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  # Not needed until we add in cloud-init tasks (e.g. disk setup)
  # user_data_base64 = data.template_cloudinit_config.kali_cloud_init_tasks.rendered

  vpc_security_group_ids = [
    aws_security_group.efs_client.id,
    aws_security_group.operations.id,
  ]

  tags        = merge(var.tags, map("Name", "Kali"))
  volume_tags = merge(var.tags, map("Name", "Kali"))
}
