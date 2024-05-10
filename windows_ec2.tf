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

  most_recent = true
  owners      = [local.images_account_id]
}

# The Windows EC2 instances
resource "aws_instance" "windows" {
  count = lookup(var.operations_instance_counts, "windows", 0)
  # These instances require a Samba instance to be present in order to
  # mount the SMB volume at boot time.
  depends_on = [
    aws_instance.samba,
    aws_security_group_rule.smb_client_egress_to_smb_server,
    aws_security_group_rule.smb_server_ingress_from_smb_client,
  ]
  provider = aws.provisionassessment

  ami                         = data.aws_ami.windows.id
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile        = aws_iam_instance_profile.windows.name
  instance_type               = var.windows_with_docker ? "c5n.metal" : "t3.xlarge"
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
    volume_size = 200
  }
  subnet_id = aws_subnet.operations.id
  tags = {
    Name = format("Windows%d", count.index)
  }
  user_data = templatefile(
    "${path.module}/ec2launch/windows-setup.tpl.yml",
    {
      drive_letter       = "N",
      samba_server_input = join(",", aws_route53_record.samba_A[*].name),
      # This should be removed once Windows AMIs are being built with the
      # correct public SSH key(s) preloaded. Please see #218 for more
      # information.
      vnc_public_ssh_key = data.aws_ssm_parameter.vnc_public_ssh_key.value,
    }
  )
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("Windows%d", count.index)
  })
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_agent_endpoint_client.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.scanner.id,
    aws_security_group.smb_client.id,
    aws_security_group.ssm_agent_endpoint_client.id,
    aws_security_group.windows.id,
  ]
}

# CloudWatch alarms for the Windows instances
module "cw_alarms_windows" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module"

  alarm_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  # The metrics written by the CloudWatch Agent have completely
  # different names in the case of Windows, so it doesn't make sense
  # to create alarms based on these metrics until we have a standard
  # set of Windows metrics.
  create_cloudwatch_agent_alarms = false
  instance_ids                   = [for instance in aws_instance.windows : instance.id]
  insufficient_data_actions      = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                     = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
