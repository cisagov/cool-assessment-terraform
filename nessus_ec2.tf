# NOTE: Most of the Nessus-related Terraform in this repo can be replaced
# with a module (e.g. "nessus-tf-module") AFTER Terraform modules support
# the use of "count" - see https://github.com/cisagov/cool-system/issues/32
# for details.

# The Nessus AMI
data "aws_ami" "nessus" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "nessus-hvm-*-x86_64-ebs"
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

# The Nessus EC2 instance
resource "aws_instance" "nessus" {
  count    = lookup(var.operations_instance_counts, "nessus", 0)
  provider = aws.provisionassessment

  # When a Nessus instance starts up, it executes cloud-init/nessus-setup.sh,
  # which requires access to the SSM and STS endpoints.  To ensure that access
  # is available, we force dependencies on the security group rules that
  # allow SSM and STS endpoint access from Nessus, as well as the endpoints
  # themselves.
  depends_on = [
    aws_security_group_rule.egress_from_ssm_endpoint_client_to_ssm_endpoint_via_https,
    aws_security_group_rule.egress_from_sts_endpoint_client_to_sts_endpoint_via_https,
    aws_security_group_rule.ingress_from_ssm_endpoint_client_to_ssm_endpoint_via_https,
    aws_security_group_rule.ingress_from_sts_endpoint_client_to_sts_endpoint_via_https,
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.sts
  ]

  ami                         = data.aws_ami.nessus.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nessus.name
  instance_type               = "m5.large"
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
  user_data_base64 = data.cloudinit_config.nessus_cloud_init_tasks[count.index].rendered
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_agent_endpoint_client.id,
    aws_security_group.guacamole_accessible.id,
    aws_security_group.nessus.id,
    aws_security_group.scanner.id,
    aws_security_group.ssm_agent_endpoint_client.id,
    aws_security_group.ssm_endpoint_client.id,
    aws_security_group.sts_endpoint_client.id,
  ]
  tags = {
    Name = format("Nessus%d", count.index)
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = format("Nessus%d", count.index)
  })
}

# The Elastic IP for each Nessus instance
resource "aws_eip" "nessus" {
  count    = lookup(var.operations_instance_counts, "nessus", 0)
  provider = aws.provisionassessment

  vpc = true
  tags = {
    Name             = format("Nessus%d EIP", count.index)
    "Publish Egress" = "True"
  }
}

# The EIP association for each Nessus instance
resource "aws_eip_association" "nessus" {
  count    = lookup(var.operations_instance_counts, "nessus", 0)
  provider = aws.provisionassessment

  instance_id   = aws_instance.nessus[count.index].id
  allocation_id = aws_eip.nessus[count.index].id
}

# CloudWatch alarms for the Nessus instances
module "cw_alarms_nessus" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module?ref=testing%2Fterraform-aws-provider_v5"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [for instance in aws_instance.nessus : instance.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
