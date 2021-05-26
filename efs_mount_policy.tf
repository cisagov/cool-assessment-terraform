# The policy doc that allows the EC2 instances to mount and write to
# the EFS
data "aws_iam_policy_document" "efs_mount_policy_doc" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite"
    ]
    effect = "Allow"
    resources = [
      # Allow mounting of the EFS mount target in the first private
      # subnet
      aws_efs_mount_target.target[var.private_subnet_cidr_blocks[0]].file_system_arn
    ]
  }
}

# The policy that allows the EC2 instances to mount and write to the
# EFS
resource "aws_iam_policy" "efs_mount_policy" {
  provider = aws.provisionassessment

  policy = data.aws_iam_policy_document.efs_mount_policy_doc.json
}
