# Security group for Terraformer instances
resource "aws_security_group" "terraformer" {
  provider = aws.provisionassessment

  tags = {
    Name = "Terraformer"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress anywhere via ssh
#
# For: Terraformer instances must be able to configure redirectors and
# operations instances via Ansible.
resource "aws_security_group_rule" "terraformer_egress_anywhere_via_ssh" {
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.terraformer.id
  to_port           = 22
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

# Allow egress anywhere via port 5986 (Windows Remote Manager).
#
# For: Terraformer instances must be able to configure Windows-based
# operations instances via Ansible.
resource "aws_security_group_rule" "terraformer_egress_to_operations_via_winrm" {
  provider = aws.provisionassessment

  cidr_blocks       = [aws_subnet.operations.cidr_block]
  from_port         = 5986
  protocol          = "tcp"
  security_group_id = aws_security_group.terraformer.id
  to_port           = 5986
  type              = "egress"
}
