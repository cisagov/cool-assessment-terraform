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
  count    = lookup(var.operations_instance_counts, "teamserver", 0)
  provider = aws.provisionassessment

  ami                         = data.aws_ami.teamserver.id
  associate_public_ip_address = true
  availability_zone           = "${var.aws_region}${var.aws_availability_zone}"
  iam_instance_profile        = aws_iam_instance_profile.teamserver.name
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.operations.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    aws_security_group.operations.id,
  ]

  tags        = merge(var.tags, map("Name", format("Teamserver%d", count.index)))
  volume_tags = merge(var.tags, map("Name", format("Teamserver%d", count.index)))
}
