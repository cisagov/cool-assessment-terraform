# The Windows AMI
data "aws_ami" "windows" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "windows-hvm-*-x86_64-ebs"
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

# The Windows EC2 instances
resource "aws_instance" "windows" {
  count    = lookup(var.operations_instance_counts, "windows", 0)
  provider = aws.provisionassessment

  ami                         = data.aws_ami.windows.id
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile        = aws_iam_instance_profile.windows.name
  instance_type               = var.windows_with_docker ? "c5n.metal" : "t3.xlarge"
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
    volume_type = "gp3"
    volume_size = 80
  }
  user_data = templatefile("${path.module}/ec2launch/windows-setup.tpl.yml", { drive_letter = "N", samba_server_input = join(",", aws_route53_record.samba_A[*].name) })
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_and_ssm_agent.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.scanner.id,
    aws_security_group.smb_client.id,
    aws_security_group.windows.id,
  ]
  tags = {
    Name = format("Windows%d", count.index)
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("Windows%d", count.index)
  })
}
