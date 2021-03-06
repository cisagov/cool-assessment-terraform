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

# The Kali EC2 instances
resource "aws_instance" "kali" {
  count = lookup(var.operations_instance_counts, "kali", 0)
  # These instances require the EFS mount target to be present in
  # order to mount the EFS volume at boot time.
  depends_on = [aws_efs_mount_target.target]
  provider   = aws.provisionassessment

  ami                         = data.aws_ami.kali.id
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile        = aws_iam_instance_profile.kali.name
  instance_type               = "t3.xlarge"
  subnet_id                   = aws_subnet.operations.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  user_data_base64 = data.cloudinit_config.kali_cloud_init_tasks.rendered

  vpc_security_group_ids = [
    aws_security_group.cloudwatch_and_ssm_agent.id,
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.kali.id,
    aws_security_group.scanner.id,
  ]

  tags        = merge(var.tags, map("Name", format("Kali%d", count.index)))
  volume_tags = merge(var.tags, map("Name", format("Kali%d", count.index)))
}
