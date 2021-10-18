# ------------------------------------------------------------------------------
# Create an IAM policy document that only allows specific instance profile
# roles to assume the role this policy is attached to.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "vnc_assume_role_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.guacamole_instance_role.arn,
        aws_iam_role.terraformer_instance_role.arn,
      ]
    }
  }
}
