# The Egress-Assess AMI
data "aws_ami" "egressassess" {
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
      "egress-assess-hvm-*-x86_64-ebs"
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

# The Egress-Assess EC2 instances
resource "aws_instance" "egressassess" {
  count = lookup(var.operations_instance_counts, "egressassess", 0)

  provider = aws.provisionassessment

  ami                         = data.aws_ami.egressassess.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.egressassess.name
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
    volume_size = 8
    volume_type = "gp3"
  }
  subnet_id = aws_subnet.operations.id
  tags = {
    Name = format("EgressAssess%d", count.index)
  }
  user_data_base64 = data.cloudinit_config.egressassess_cloud_init_tasks[count.index].rendered
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("EgressAssess%d", count.index)
  })
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_agent_endpoint_client.id,
    aws_security_group.egressassess.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.ssm_agent_endpoint_client.id,
  ]
}

# The Elastic IP for each Egress-Assess instance
resource "aws_eip" "egressassess" {
  count    = lookup(var.operations_instance_counts, "egressassess", 0)
  provider = aws.provisionassessment

  tags = {
    Name             = format("EgressAssess%d EIP", count.index)
    "Publish Egress" = var.publish_egress_ip_addresses
  }
  vpc = true
}

# The EIP association for each Egress-Assess instance
resource "aws_eip_association" "egressassess" {
  count    = lookup(var.operations_instance_counts, "egressassess", 0)
  provider = aws.provisionassessment

  allocation_id = aws_eip.egressassess[count.index].id
  instance_id   = aws_instance.egressassess[count.index].id
}

# CloudWatch alarms for the Egress-Assess instances
module "cw_alarms_egressassess" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [for instance in aws_instance.egressassess : instance.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
