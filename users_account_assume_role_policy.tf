# ------------------------------------------------------------------------------
# Create an IAM policy document that allows the users account to
# assume a role.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "users_account_assume_role_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      identifiers = [
        local.users_account_id,
      ]
      type = "AWS"
    }
  }
}
