# ------------------------------------------------------------------------------
# Create the IAM role that allows creation of SSM SessionManager
# sessions to any EC2 instance in this account.
# ------------------------------------------------------------------------------

resource "aws_iam_role" "ssmsession_role" {
  provider = aws.provisionassessment

  assume_role_policy = data.aws_iam_policy_document.users_account_assume_role_doc.json
  description        = var.ssmsession_role_description
  name               = var.ssmsession_role_name
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ssmsession_policy_attachment" {
  provider = aws.provisionassessment

  policy_arn = aws_iam_policy.ssmsession_policy.arn
  role       = aws_iam_role.ssmsession_role.name
}
