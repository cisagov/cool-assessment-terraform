# The Debian AMI, which we use for our "Debian desktop" instances
data "aws_ami" "debiandesktop" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "debian-hvm-*-x86_64-ebs"
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

# The "Debian desktop" EC2 instances
resource "aws_instance" "debiandesktop" {
  count = lookup(var.operations_instance_counts, "debiandesktop", 0)
  # These instances require the EFS mount target to be present in
  # order to mount the EFS volume at boot time.
  depends_on = [aws_efs_mount_target.target]
  provider   = aws.provisionassessment

  ami                         = data.aws_ami.debiandesktop.id
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile        = aws_iam_instance_profile.debiandesktop.name
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.operations.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  # We can use the same cloud-init code as the Kali instances, since
  # all it does is set up /etc/fstab to mount the EFS file share.
  user_data_base64 = data.cloudinit_config.kali_cloud_init_tasks.rendered

  # Even though the Debian desktop instances are in the Operations subnet,
  # we put them in the "debiandesktop" security group.  This means that the
  # ports in "operations_subnet_inbound_tcp_ports_allowed" and
  # "operations_subnet_inbound_udp_ports_allowed", which are normally allowed
  # inbound to Operations instances from anywhere, DO NOT APPLY to
  # Debian desktop instances.
  vpc_security_group_ids = [
    aws_security_group.debiandesktop.id,
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
  ]

  tags        = merge(var.tags, map("Name", format("DebianDesktop%d", count.index)))
  volume_tags = merge(var.tags, map("Name", format("DebianDesktop%d", count.index)))
}
