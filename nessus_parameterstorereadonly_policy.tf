# ------------------------------------------------------------------------------
# Create the IAM policy that allows read-only access to the Nessus-related
# SSM Parameter Store parameters in the Images account.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "nessus_parameterstorereadonly_doc" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      format("arn:aws:ssm:*:%s:parameter%s", local.images_account_id, var.ssm_key_nessus_admin_username),
      format("arn:aws:ssm:*:%s:parameter%s", local.images_account_id, var.ssm_key_nessus_admin_password)
    ]
  }
}

resource "aws_iam_policy" "nessus_parameterstorereadonly_policy" {
  provider = aws.provisionparameterstorereadrole

  description = local.nessus_parameterstorereadonly_role_description
  name        = local.nessus_parameterstorereadonly_role_name
  policy      = data.aws_iam_policy_document.nessus_parameterstorereadonly_doc.json
}
