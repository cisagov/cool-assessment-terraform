# The teamserver AMI
data "aws_ami" "teamserver" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "teamserver-hvm-*-x86_64-ebs"
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

# The teamserver EC2 instances
resource "aws_instance" "teamserver" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)
  # These instances require the EFS mount target to be present in
  # order to mount the EFS volume at boot time.
  #
  # When a Teamserver instance starts up, it executes cloud-init
  # scripts which require access to the S3 and STS endpoints.  To
  # ensure that access is available, we force dependencies on the
  # security group rules that allow STS endpoint access from the
  # Teamserver, as well as the endpoints themselves.
  depends_on = [
    aws_efs_mount_target.target,
    aws_security_group_rule.egress_to_s3_endpoint_via_https,
    aws_security_group_rule.ingress_from_sts_endpoint_client_to_sts_endpoint_via_https,
    aws_vpc_endpoint.s3,
    aws_vpc_endpoint.sts,
  ]
  provider = aws.provisionassessment

  ami                         = data.aws_ami.teamserver.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.teamserver[count.index].name
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.operations.id
  root_block_device {
    volume_size = 128
    volume_type = "gp3"
  }
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
  user_data_base64 = data.cloudinit_config.teamserver_cloud_init_tasks[count.index].rendered
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_and_ssm_agent.id,
    aws_security_group.cloudwatch_endpoint_client.id,
    aws_security_group.efs_client.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.s3_endpoint_client.id,
    aws_security_group.scanner.id,
    aws_security_group.ssm_endpoint_client.id,
    aws_security_group.sts_endpoint_client.id,
    aws_security_group.teamserver.id,
  ]
  tags = {
    Name = format("Teamserver%d", count.index)
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("Teamserver%d", count.index)
  })
}

# The Elastic IP for each teamserver
resource "aws_eip" "teamserver" {
  count    = lookup(var.operations_instance_counts, "teamserver", 0)
  provider = aws.provisionassessment

  vpc = true
  tags = {
    Name             = format("Teamserver%d EIP", count.index)
    "Publish Egress" = "True"
  }
}

# The EIP association for each teamserver
resource "aws_eip_association" "teamserver" {
  count    = lookup(var.operations_instance_counts, "teamserver", 0)
  provider = aws.provisionassessment

  instance_id   = aws_instance.teamserver[count.index].id
  allocation_id = aws_eip.teamserver[count.index].id
}

# CloudWatch alarms for the teamserver instances
module "cw_alarms_teamserver" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [for instance in aws_instance.teamserver : instance.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
