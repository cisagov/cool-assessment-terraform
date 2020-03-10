# ------------------------------------------------------------------------------
# Create an IAM policy document that allows EC2 instances
# to assume the role this policy is attached to.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "vnc_assume_role_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}
