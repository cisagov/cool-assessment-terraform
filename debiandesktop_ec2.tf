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
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.operations.id
  # AWS Instance Meta-Data Service (IMDS) options
  metadata_options {
    # Enable IMDS (this is the default value)
    http_endpoint = "enabled"
    # Restrict put responses from IMDS to a single hop (this is the
    # default value).  This effectively disallows the retrieval of an
    # IMDSv2 token via this machine from anywhere else.
    http_put_response_hop_limit = 1
    # Require IMDS tokens AKA require the use of IMDSv2
    http_tokens = "required"
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }
  # We can use the same cloud-init code as the Kali instances, since
  # all it does is set up /etc/fstab to mount the EFS file share.
  user_data_base64 = data.cloudinit_config.kali_cloud_init_tasks.rendered
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_and_ssm_agent.id,
    aws_security_group.debiandesktop.id,
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
  ]
  tags        = merge(var.tags, map("Name", format("DebianDesktop%d", count.index)))
  volume_tags = merge(var.tags, map("Name", format("DebianDesktop%d", count.index)))
}
