# The Assessor Portal AMI
data "aws_ami" "assessorportal" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "assessor-portal-hvm-*-x86_64-ebs"
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

# The Assessor Portal EC2 instances
resource "aws_instance" "assessorportal" {
  count = lookup(var.operations_instance_counts, "assessorportal", 0)
  # These instances require the EFS mount target to be present in
  # order to mount the EFS volume at boot time.
  depends_on = [aws_efs_mount_target.target]
  provider   = aws.provisionassessment

  ami                         = data.aws_ami.assessorportal.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.assessorportal.name
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
  user_data_base64 = data.cloudinit_config.assessorportal_cloud_init_tasks[count.index].rendered
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_and_ssm_agent.id,
    aws_security_group.assessorportal.id,
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
  ]
  tags = {
    Name = format("AssessorPortal%d", count.index)
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("AssessorPortal%d", count.index)
  })
}

# The EBS volume for each Assessor Portal instance; it is used to persist
# Docker volume data across instance restarts and redeployments.  Note that
# Docker data cannot be stored on the existing EFS volume because EFS is not
# supported as a backing file system for Docker:
# https://docs.docker.com/storage/storagedriver/select-storage-driver/#supported-backing-filesystems
resource "aws_ebs_volume" "assessorportal_docker" {
  count    = lookup(var.operations_instance_counts, "assessorportal", 0)
  provider = aws.provisionassessment

  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  encrypted         = true
  size              = 16
  type              = "gp3"

  tags = {
    Name = format("AssessorPortal%d Docker", count.index)
  }
}

# Attach EBS volume to Assessor Portal instance
resource "aws_volume_attachment" "assessorportal_docker" {
  count    = lookup(var.operations_instance_counts, "assessorportal", 0)
  provider = aws.provisionassessment

  device_name = local.docker_ebs_device_name
  instance_id = aws_instance.assessorportal[count.index].id
  volume_id   = aws_ebs_volume.assessorportal_docker[count.index].id
}

# CloudWatch alarms for the Assessor Portal instances
module "cw_alarms_assessor_portal" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [for instance in aws_instance.assessorportal : instance.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
