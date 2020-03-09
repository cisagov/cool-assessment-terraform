# ------------------------------------------------------------------------------
# Create the IAM role that allows read-only access to the VNC-related
# SSM Parameter Store parameters in the Images account.
# ------------------------------------------------------------------------------

resource "aws_iam_role" "vnc_parameterstorereadonly_role" {
  provider = aws.provisionparameterstorereadrole

  assume_role_policy = data.aws_iam_policy_document.vnc_assume_role_doc.json
  description        = local.vnc_parameterstorereadonly_role_description
  name               = local.vnc_parameterstorereadonly_role_name
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "vnc_parameterstorereadonly_policy_attachment" {
  provider = aws.provisionparameterstorereadrole

  policy_arn = aws_iam_policy.vnc_parameterstorereadonly_policy.arn
  role       = aws_iam_role.vnc_parameterstorereadonly_role.name
}
