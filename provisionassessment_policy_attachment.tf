# ------------------------------------------------------------------------------
# Attach to the ProvisionAccount role the IAM policy that allows
# provisioning of the resources required in the assessment account.
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "provisionassessment_policy_attachment" {
  provider = "aws.provisionassessment"

  policy_arn = aws_iam_policy.provisionassessment_policy.arn
  role       = var.provisionaccount_role_name
}
