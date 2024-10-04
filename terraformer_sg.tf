# Security group for Terraformer instances
resource "aws_security_group" "terraformer" {
  provider = aws.provisionassessment

  tags = {
    Name = "Terraformer"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress anywhere via ssh and WinRM
#
# For: Terraformer instances must be able to configure redirectors and
# operations instances via Ansible, some of which may be
# Windows-based.
resource "aws_security_group_rule" "terraformer_egress_anywhere_via_ssh_and_winrm" {
  provider = aws.provisionassessment
  for_each = {
    ssh = {
      port = 22,
    },
    winrm_unencrypted = {
      port = 5985,
    },
    winrm_encrypted = {
      port = 5986,
    },
  }

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value.port
  protocol          = "tcp"
  security_group_id = aws_security_group.terraformer.id
  to_port           = each.value.port
  type              = "egress"
}

# Allow egress anywhere via HTTP
#
# For: Terraformer instances must be able to install packages.
resource "aws_security_group_rule" "terraformer_egress_anywhere_via_http" {
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.terraformer.id
  to_port           = 80
  type              = "egress"
}

# Allow egress anywhere via HTTPS
#
# For: Terraformer instances must be able to terraform init.
resource "aws_security_group_rule" "terraformer_egress_anywhere_via_https" {
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.terraformer.id
  to_port           = 443
  type              = "egress"
}
