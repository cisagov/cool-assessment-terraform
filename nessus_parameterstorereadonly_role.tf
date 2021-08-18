# ------------------------------------------------------------------------------
# Create the IAM role that allows read-only access to the Nessus-related
# SSM Parameter Store parameters in the Images account.
# ------------------------------------------------------------------------------

resource "aws_iam_role" "nessus_parameterstorereadonly_role" {
  provider = aws.provisionparameterstorereadrole

  assume_role_policy = data.aws_iam_policy_document.nessus_assume_role_doc.json
  description        = local.nessus_parameterstorereadonly_role_description
  name               = local.nessus_parameterstorereadonly_role_name
}

resource "aws_iam_role_policy_attachment" "nessus_parameterstorereadonly_policy_attachment" {
  provider = aws.provisionparameterstorereadrole

  policy_arn = aws_iam_policy.nessus_parameterstorereadonly_policy.arn
  role       = aws_iam_role.nessus_parameterstorereadonly_role.name
}
