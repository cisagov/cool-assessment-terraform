# ------------------------------------------------------------------------------
# Create an IAM policy document that allows the users account to
# assume this role.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "users_account_assume_role_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"
      identifiers = [
        local.users_account_id,
      ]
    }
  }
}
