# ------------------------------------------------------------------------------
# Create the IAM policy that allows read-only access to the VNC-related
# SSM Parameter Store parameters in the Images account.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "vnc_parameterstorereadonly_doc" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = formatlist("arn:aws:ssm:*:%s:parameter%s", local.images_account_id, ["/vnc/*", "/rdp/*"])
  }
}

resource "aws_iam_policy" "vnc_parameterstorereadonly_policy" {
  provider = aws.provisionparameterstorereadrole

  description = local.vnc_parameterstorereadonly_role_description
  name        = local.vnc_parameterstorereadonly_role_name
  policy      = data.aws_iam_policy_document.vnc_parameterstorereadonly_doc.json
}
