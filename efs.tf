# The EFS file system
resource "aws_efs_file_system" "persistent_storage" {
  provider = aws.provisionassessment

  encrypted = true
  tags = merge(
    var.tags,
    {
      "Name" = "Persistent Storage"
    },
  )
}

# Mount points for EFS
resource "aws_efs_mount_target" "target" {
  provider = aws.provisionassessment
  for_each = toset([for subnet in aws_subnet.private : subnet.id])

  file_system_id  = aws_efs_file_system.persistent_storage.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs_mount_target.id]
}

# EFS security group
resource "aws_security_group" "efs_mount_target" {
  provider = aws.provisionassessment

  tags = merge(
    var.tags,
    {
      "Name" = "EFS Mount Target"
    },
  )
  vpc_id = aws_vpc.assessment.id
}
resource "aws_security_group_rule" "allow_nfs_inbound" {
  provider = aws.provisionassessment

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs_mount_target.id
  source_security_group_id = aws_security_group.efs_client.id
}

# EFS client security group
resource "aws_security_group" "efs_client" {
  provider = aws.provisionassessment

  tags = merge(
    var.tags,
    {
      "Name" = "EFS Client"
    },
  )
  vpc_id = aws_vpc.assessment.id
}
resource "aws_security_group_rule" "allow_nfs_outbound" {
  provider = aws.provisionassessment

  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs_client.id
  source_security_group_id = aws_security_group.efs_mount_target.id
}
