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
  depends_on = [
    aws_efs_mount_target.target,
    aws_security_group_rule.allow_nfs_inbound,
    aws_security_group_rule.allow_nfs_outbound,
  ]
  provider = aws.provisionassessment

  ami                         = data.aws_ami.debiandesktop.id
  associate_public_ip_address = true
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
    volume_size = 128
    volume_type = "gp3"
  }
  user_data_base64 = data.cloudinit_config.debiandesktop_cloud_init_tasks[count.index].rendered
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_agent_endpoint_client.id,
    aws_security_group.debiandesktop.id,
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.ssm_agent_endpoint_client.id,
  ]
  tags = {
    Name = format("DebianDesktop%d", count.index)
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("DebianDesktop%d", count.index)
  })
}

# CloudWatch alarms for the Debian Desktop instances
module "cw_alarms_debiandesktop" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [for instance in aws_instance.debiandesktop : instance.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
