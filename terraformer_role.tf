# Create the IAM role for the Terraformer EC2 server instances that
# allows them to create/destroy/modify the appropriate (and _only_ the
# appropriate) resources in this account.

resource "aws_iam_role" "terraformer_role" {
  provider = aws.provisionassessment

  assume_role_policy   = data.aws_iam_policy_document.terraformer_assume_role_doc.json
  description          = var.terraformer_role_description
  name                 = var.terraformer_role_name
  permissions_boundary = aws_iam_policy.terraformer_permissions_boundary_policy.arn
}

# Allow full access to new resources and existing resources that _are
# not_ tagged as being created by the team that deploys this root
# module (with a few exceptions; see policy for details).
resource "aws_iam_role_policy_attachment" "terraformer_policy_attachment" {
  provider = aws.provisionassessment

  policy_arn = aws_iam_policy.terraformer_policy.arn
  role       = aws_iam_role.terraformer_role.name
}
