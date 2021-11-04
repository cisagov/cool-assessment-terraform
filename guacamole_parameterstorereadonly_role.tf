# ------------------------------------------------------------------------------
# Create the IAM role that allows read-only access to the Guacamole-related
# SSM Parameter Store parameters in the Images account.
# ------------------------------------------------------------------------------

resource "aws_iam_role" "gucamole_parameterstorereadonly_role" {
  provider = aws.provisionparameterstorereadrole

  assume_role_policy = data.aws_iam_policy_document.vnc_assume_role_doc.json
  description        = local.gucamole_parameterstorereadonly_role_description
  name               = local.gucamole_parameterstorereadonly_role_name
}

resource "aws_iam_role_policy_attachment" "gucamole_parameterstorereadonly_policy_attachment" {
  provider = aws.provisionparameterstorereadrole

  policy_arn = aws_iam_policy.gucamole_parameterstorereadonly_policy.arn
  role       = aws_iam_role.gucamole_parameterstorereadonly_role.name
}
