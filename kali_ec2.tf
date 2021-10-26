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
  iam_instance_profile        = aws_iam_instance_profile.kali.name
  instance_type               = "t3.xlarge"
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
    volume_type           = "gp3"
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
  tags = {
    Name = format("Kali%d", count.index)
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("Kali%d", count.index)
  })
}

# The Elastic IP for each Kali instance
resource "aws_eip" "kali" {
  count    = lookup(var.operations_instance_counts, "kali", 0)
  provider = aws.provisionassessment

  vpc = true
  tags = {
    Name             = format("Kali%d EIP", count.index)
    "Publish Egress" = "True"
  }
}

# The EIP association for each Kali instance
resource "aws_eip_association" "kali" {
  count    = lookup(var.operations_instance_counts, "kali", 0)
  provider = aws.provisionassessment

  instance_id   = aws_instance.kali[count.index].id
  allocation_id = aws_eip.kali[count.index].id
}
