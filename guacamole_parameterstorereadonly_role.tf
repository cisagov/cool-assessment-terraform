# ------------------------------------------------------------------------------
# Create the IAM role that allows read-only access to the Guacamole-related
# SSM Parameter Store parameters in the Images account.
# ------------------------------------------------------------------------------

resource "aws_iam_role" "guacamole_parameterstorereadonly_role" {
  provider = aws.provisionparameterstorereadrole

  assume_role_policy = data.aws_iam_policy_document.guacamole_parameterstore_assume_role_doc.json
  description        = local.guacamole_parameterstorereadonly_role_description
  name               = local.guacamole_parameterstorereadonly_role_name
}

resource "aws_iam_role_policy_attachment" "guacamole_parameterstorereadonly_policy_attachment" {
  provider = aws.provisionparameterstorereadrole

  policy_arn = aws_iam_policy.guacamole_parameterstorereadonly_policy.arn
  role       = aws_iam_role.guacamole_parameterstorereadonly_role.name
}
