# The Teamserver AMI
data "aws_ami" "teamserver" {
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

  most_recent = true
  owners      = [local.images_account_id]
}

# The Teamserver EC2 instances
resource "aws_instance" "teamserver" {
  ami                         = data.aws_ami.teamserver.id
  associate_public_ip_address = true
  iam_instance_profile        = data.terraform_remote_state.cool_assessment_terraform.outputs.teamserver_instance_profile.name
  instance_type               = "t3.large"
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
  subnet_id = data.terraform_remote_state.cool_assessment_terraform.outputs.operations_subnet.id
  tags = {
    Name = "Teamserver"
  }
  user_data_base64 = data.cloudinit_config.teamserver_cloud_init_tasks.rendered
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = "Teamserver"
  })
  vpc_security_group_ids = [
    data.terraform_remote_state.cool_assessment_terraform.outputs.cloudwatch_and_ssm_agent_security_group.id,
    data.terraform_remote_state.cool_assessment_terraform.outputs.efs_client_security_group.id,
    data.terraform_remote_state.cool_assessment_terraform.outputs.guacamole_accessible_security_group.id,
    data.terraform_remote_state.cool_assessment_terraform.outputs.scanner_security_group.id,
    data.terraform_remote_state.cool_assessment_terraform.outputs.teamserver_security_group.id,
  ]
}

# The Elastic IP for the Teamserver
resource "aws_eip" "teamserver" {
  tags = {
    Name             = "Teamserver EIP"
    "Publish Egress" = "True"
  }
  vpc = true
}

# The EIP association for the Teamserver
resource "aws_eip_association" "teamserver" {
  allocation_id = aws_eip.teamserver.id
  instance_id   = aws_instance.teamserver.id
}
