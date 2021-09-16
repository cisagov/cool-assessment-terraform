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

  owners      = [local.images_account_id]
  most_recent = true
}

# The Teamserver EC2 instances
resource "aws_instance" "teamserver" {
  ami                         = data.aws_ami.teamserver.id
  associate_public_ip_address = true
  iam_instance_profile        = data.terraform_remote_state.cool_assessment_terraform.outputs.teamserver_instance_profile.name
  instance_type               = "t3.large"
  subnet_id                   = data.terraform_remote_state.cool_assessment_terraform.outputs.operations_subnet.id
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
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
  user_data_base64 = data.cloudinit_config.teamserver_cloud_init_tasks.rendered
  vpc_security_group_ids = [
    data.terraform_remote_state.cool_assessment_terraform.outputs.cloudwatch_and_ssm_agent_security_group.id,
    data.terraform_remote_state.cool_assessment_terraform.outputs.efs_client_security_group.id,
    data.terraform_remote_state.cool_assessment_terraform.outputs.guacamole_accessible_security_group.id,
    data.terraform_remote_state.cool_assessment_terraform.outputs.scanner_security_group.id,
    data.terraform_remote_state.cool_assessment_terraform.outputs.teamserver_security_group.id,
  ]
  tags = {
    Name = "Teamserver"
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(data.aws_default_tags.assessment.tags, {
    Name = "Teamserver"
  })
}

# The Elastic IP for the teamserver
resource "aws_eip" "teamserver" {
  vpc = true
  tags = {
    Name             = "Teamserver EIP"
    "Publish Egress" = "True"
  }
}

# The EIP association for the teamserver
resource "aws_eip_association" "teamserver" {
  instance_id   = aws_instance.teamserver.id
  allocation_id = aws_eip.teamserver.id
}
