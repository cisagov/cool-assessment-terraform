# ------------------------------------------------------------------------------
# Create the IAM role that allows read-only access to the Nessus-related
# SSM Parameter Store parameters in the Images account.
# ------------------------------------------------------------------------------

resource "aws_iam_role" "nessus_parameterstorereadonly_role" {
  count    = lookup(var.operations_instance_counts, "nessus", 0) > 0 ? 1 : 0
  provider = aws.provisionparameterstorereadrole

  assume_role_policy = data.aws_iam_policy_document.nessus_assume_role_doc[count.index].json
  description        = local.nessus_parameterstorereadonly_role_description
  name               = local.nessus_parameterstorereadonly_role_name
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "nessus_parameterstorereadonly_policy_attachment" {
  count    = lookup(var.operations_instance_counts, "nessus", 0) > 0 ? 1 : 0
  provider = aws.provisionparameterstorereadrole

  policy_arn = aws_iam_policy.nessus_parameterstorereadonly_policy[count.index].arn
  role       = aws_iam_role.nessus_parameterstorereadonly_role[count.index].name
}
