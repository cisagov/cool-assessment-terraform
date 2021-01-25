# The teamserver AMI
data "aws_ami" "teamserver" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "teamserver-hvm-*-x86_64-ebs"
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

# The teamserver EC2 instances
resource "aws_instance" "teamserver" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)
  # These instances require the EFS mount target to be present in
  # order to mount the EFS volume at boot time.
  depends_on = [aws_efs_mount_target.target]
  provider   = aws.provisionassessment

  ami                         = data.aws_ami.teamserver.id
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile        = aws_iam_instance_profile.teamserver.name
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.operations.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  # We can use the same cloud-init code as the Kali instances, since
  # all it does is set up /etc/fstab to mount the EFS file share.
  user_data_base64 = data.cloudinit_config.kali_cloud_init_tasks.rendered

  vpc_security_group_ids = [
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.operations.id,
    aws_security_group.teamserver.id,
  ]

  tags        = merge(var.tags, map("Name", format("Teamserver%d", count.index)))
  volume_tags = merge(var.tags, map("Name", format("Teamserver%d", count.index)))
}

# The Elastic IP for each teamserver
resource "aws_eip" "teamserver" {
  count    = lookup(var.operations_instance_counts, "teamserver", 0)
  provider = aws.provisionassessment

  vpc = true
  tags = merge(
    var.tags,
    {
      "Name"           = format("Teamserver%d EIP", count.index)
      "Publish Egress" = "True"
    },
  )
}

# The EIP association for each teamserver
resource "aws_eip_association" "teamserver" {
  count    = lookup(var.operations_instance_counts, "teamserver", 0)
  provider = aws.provisionassessment

  instance_id   = aws_instance.teamserver[count.index].id
  allocation_id = aws_eip.teamserver[count.index].id
}
