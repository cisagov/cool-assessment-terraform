# The Terraformer AMI
data "aws_ami" "terraformer" {
  provider = aws.provisionassessment

  most_recent = true
  owners      = [local.images_account_id]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name = "name"
    values = [
      "terraformer-hvm-*-arm64-ebs"
    ]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# The Terraformer EC2 instances
resource "aws_instance" "terraformer" {
  count = lookup(var.operations_instance_counts, "terraformer", 0)
  # These instances require the EFS mount target to be present in
  # order to mount the EFS volume at boot time.
  depends_on = [
    aws_efs_mount_target.target,
    aws_security_group_rule.allow_nfs_inbound,
    aws_security_group_rule.allow_nfs_outbound,
  ]
  provider = aws.provisionassessment

  ami                  = data.aws_ami.terraformer.id
  iam_instance_profile = aws_iam_instance_profile.terraformer.name
  instance_type        = "t4g.xlarge"
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
  # TODO: For some reason I can't ssh via SSM to the instance unless I
  # put it in the first private subnet.  I believe this has something
  # to do with the NACLs that are in place for that subnet
  # specifically.  I will figure this out later.  I'd definitely
  # prefer to put this instance in a different subnet than the
  # Guacamole instance.
  #
  # See cisagov/cool-assessment-terraform#135 for more details.
  subnet_id = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  tags = {
    Name = format("Terraformer%d", count.index)
  }
  user_data_base64 = data.cloudinit_config.terraformer_cloud_init_tasks[count.index].rendered
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("Terraformer%d", count.index)
  })
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_agent_endpoint_client.id,
    aws_security_group.dynamodb_endpoint_client.id,
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.s3_endpoint_client.id,
    aws_security_group.ssm_agent_endpoint_client.id,
    aws_security_group.sts_endpoint_client.id,
    aws_security_group.terraformer.id,
  ]
}

# CloudWatch alarms for the Terraformer instances
module "cw_alarms_terraformer" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [for instance in aws_instance.terraformer : instance.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
