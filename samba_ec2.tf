# The Samba AMI
data "aws_ami" "samba" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "samba-hvm-*-x86_64-ebs"
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

# The Samba EC2 instances
resource "aws_instance" "samba" {
  count = lookup(var.operations_instance_counts, "samba", 0)
  # These instances require the EFS mount target to be present in
  # order to mount the EFS volume at boot time.
  depends_on = [
    aws_efs_mount_target.target,
    aws_security_group_rule.allow_nfs_inbound,
    aws_security_group_rule.allow_nfs_outbound,
  ]
  provider = aws.provisionassessment

  ami                  = data.aws_ami.samba.id
  iam_instance_profile = aws_iam_instance_profile.samba.name
  instance_type        = "t3.small"
  # TODO: For some reason I can't ssh via SSM to the instance unless I
  # put it in the first private subnet.  I believe this has something
  # to do with the NACLs that are in place for that subnet
  # specifically.  I will figure this out later.  I'd definitely
  # prefer to put this instance in a different subnet than the
  # Guacamole instance.
  #
  # See cisagov/cool-assessment-terraform#135 for more details.
  subnet_id = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
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
    volume_size = 16
    volume_type = "gp3"
  }
  user_data_base64 = data.cloudinit_config.samba_cloud_init_tasks[count.index].rendered
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_agent_endpoint_client.id,
    aws_security_group.efs_client.id,
    aws_security_group.smb_server.id,
    aws_security_group.ssm_agent_endpoint_client.id,
  ]
  tags = {
    Name = format("Samba%d", count.index)
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("Samba%d", count.index)
  })
}

# CloudWatch alarms for the Samba instances
module "cw_alarms_samba" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module?ref=testing%2Fterraform-aws-provider_v5"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [for instance in aws_instance.samba : instance.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
