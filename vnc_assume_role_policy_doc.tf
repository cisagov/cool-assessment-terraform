# ------------------------------------------------------------------------------
# Create an IAM policy document that allows the EC2 instances in the
# assessment account to assume a role.
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

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.assessment_account_id}:root",
      ]
    }
  }
}
