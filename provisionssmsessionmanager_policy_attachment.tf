# ------------------------------------------------------------------------------
# Attach to the ProvisionAccount role the IAM policy that allows
# provisioning of the SSM Document resource and set up SSM session
# logging in this account.
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "provisionssmsessionmanager_policy_attachment" {
  provider = aws.provisionassessment

  policy_arn = aws_iam_policy.provisionssmsessionmanager_policy.arn
  role       = var.provisionaccount_role_name
}
