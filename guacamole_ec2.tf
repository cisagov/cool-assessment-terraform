# The Guacamole AMI
data "aws_ami" "guacamole" {
  provider = aws.provisionassessment

  filter {
    name = "name"
    values = [
      "guacamole-hvm-*-x86_64-ebs"
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

# The Guacamole EC2 instance
resource "aws_instance" "guacamole" {
  provider = aws.provisionassessment

  # When a Guacamole instance starts up, it executes cloud-init scripts
  # which require access to the S3, SSM, and STS endpoints.  To ensure that
  # access is available, we force dependencies on the security group rules that
  # allow SSM and STS endpoint access from Guacamole, as well as the endpoints
  # themselves.
  depends_on = [
    aws_security_group_rule.egress_from_ec2_endpoint_client_to_ec2_endpoint_via_https,
    aws_security_group_rule.egress_from_ssm_endpoint_client_to_ssm_endpoint_via_https,
    aws_security_group_rule.egress_from_sts_endpoint_client_to_sts_endpoint_via_https,
    aws_security_group_rule.egress_to_s3_endpoint_via_https,
    aws_security_group_rule.ingress_from_ec2_endpoint_client_to_ec2_endpoint_via_https,
    aws_security_group_rule.ingress_from_ssm_endpoint_client_to_ssm_endpoint_via_https,
    aws_security_group_rule.ingress_from_sts_endpoint_client_to_sts_endpoint_via_https,
    aws_vpc_endpoint.ec2,
    aws_vpc_endpoint.s3,
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.sts
  ]

  ami                  = data.aws_ami.guacamole.id
  iam_instance_profile = aws_iam_instance_profile.guacamole.name
  instance_type        = "t3.medium"
  subnet_id            = aws_subnet.private[var.private_subnet_cidr_blocks[0]].id
  # AWS Instance Meta-Data Service (IMDS) options
  metadata_options {
    # Enable IMDS (this is the default value)
    http_endpoint = "enabled"
    # Normally we restrict put responses from IMDS to a single hop
    # (this is the default value).  This effectively disallows the
    # retrieval of an IMDSv2 token via this machine from anywhere
    # else.
    #
    # In this case we set the hop limit to two, since we want the
    # cisagov/guacscanner-docker Docker container hosted on this
    # instance to be able to retrieve from IMDS the ID of the VPC in
    # which the instance resides.
    http_put_response_hop_limit = 2
    # Require IMDS tokens AKA require the use of IMDSv2
    http_tokens = "required"
  }
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
  user_data_base64 = data.cloudinit_config.guacamole_cloud_init_tasks.rendered
  vpc_security_group_ids = [
    aws_security_group.cloudwatch_and_ssm_agent.id,
    aws_security_group.cloudwatch_endpoint_client.id,
    aws_security_group.ec2_endpoint_client.id,
    aws_security_group.guacamole.id,
    aws_security_group.s3_endpoint_client.id,
    aws_security_group.ssm_endpoint_client.id,
    aws_security_group.sts_endpoint_client.id,
  ]
  tags = {
    Name = "Guacamole"
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = "Guacamole"
  })
}

# CloudWatch alarms for the Guacamole instances
module "cw_alarms_guacamole" {
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/instance-cw-alarms-tf-module"

  alarm_actions             = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  instance_ids              = [aws_instance.guacamole.id]
  insufficient_data_actions = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
  ok_actions                = [data.terraform_remote_state.dynamic_assessment.outputs.cw_alarm_sns_topic.arn]
}
