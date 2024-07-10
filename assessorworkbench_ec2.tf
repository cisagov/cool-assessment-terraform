# The Assessor Workbench AMI
data "aws_ami" "assessorworkbench" {
  provider = aws.provisionassessment

  most_recent = true
  owners      = [local.images_account_id]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "name"
    values = [
      "assessor-workbench-hvm-*-x86_64-ebs"
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

# The Assessor Workbench EC2 instances
resource "aws_instance" "assessorworkbench" {
  count = lookup(var.operations_instance_counts, "assessorworkbench", 0)
  # These instances require the EBS Docker volume and EFS mount target
  # to be present so that both volumes can be mounted at boot time.
  depends_on = [
    aws_ebs_volume.assessorworkbench_docker,
    aws_efs_mount_target.target,
    aws_security_group_rule.allow_nfs_inbound,
    aws_security_group_rule.allow_nfs_outbound,
  ]
  provider = aws.provisionassessment

  ami                         = data.aws_ami.assessorworkbench.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.assessorworkbench.name
  instance_type               = "t3.medium"
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
  subnet_id = aws_subnet.operations.id
  tags = {
    Name = format("AssessorWorkbench%d", count.index)
  }
  user_data_base64 = data.cloudinit_config.assessorworkbench_cloud_init_tasks[count.index].rendered
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("AssessorWorkbench%d", count.index)
  })
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_agent_endpoint_client.id,
    aws_security_group.assessorworkbench.id,
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.ssm_agent_endpoint_client.id,
  ]
}

# The EBS volume for each Assessor Workbench instance; it is used to
# persist Docker volume data across instance restarts and
# redeployments.  Note that Docker data cannot be stored on the
# existing EFS volume because EFS is not supported as a backing file
# system for Docker:
# https://docs.docker.com/storage/storagedriver/select-storage-driver/#supported-backing-filesystems
resource "aws_ebs_volume" "assessorworkbench_docker" {
  count    = lookup(var.operations_instance_counts, "assessorworkbench", 0)
  provider = aws.provisionassessment

  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  encrypted         = true
  size              = 16
  tags = {
    Name = format("AssessorWorkbench%d Docker", count.index)
  }
  type = "gp3"
}

# Attach EBS volume to Assessor Workbench instance
resource "aws_volume_attachment" "assessorworkbench_docker" {
  count    = lookup(var.operations_instance_counts, "assessorworkbench", 0)
  provider = aws.provisionassessment

  device_name                    = local.docker_ebs_device_name
  instance_id                    = aws_instance.assessorworkbench[count.index].id
  stop_instance_before_detaching = true
  volume_id                      = aws_ebs_volume.assessorworkbench_docker[count.index].id
}

# CloudWatch alarms for the Assessor Workbench instances
module "cw_alarms_assessor_workbench" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [for instance in aws_instance.assessorworkbench : instance.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
