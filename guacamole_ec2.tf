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

  # When a Guacamole instance starts up, it executes cloud-init scripts
  # which require access to the S3, SSM, and STS endpoints.  To ensure that
  # access is available, we force dependencies on the security group rules that
  # allow SSM and STS endpoint access from Guacamole, as well as the endpoints
  # themselves.  Note that there is no security group rule for S3 because
  # it's a _gateway_ endpoint, while SSM and STS are _interface_ endpoints.
  depends_on = [
    aws_security_group_rule.ingress_from_guacamole_to_ssm_via_https,
    aws_security_group_rule.ingress_from_guacamole_to_sts_via_https,
    aws_vpc_endpoint.s3,
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.sts
  ]

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
    aws_security_group.cloudwatch_and_ssm_agent.id,
    aws_security_group.guacamole.id,
  ]

  tags        = merge(var.tags, map("Name", "Guacamole"))
  volume_tags = merge(var.tags, map("Name", "Guacamole"))
}
