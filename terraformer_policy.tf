# Create the IAM policy for the Terraformer EC2 server instances that
# allows full access to create/destroy new resources in this account
# and create/modify/destroy existing resources not created by the "VM
# Fusion - Development" team.

data "aws_iam_policy_document" "full_access_doc" {
  provider = aws.provisionassessment

  # Allow full access to new resources and existing resources that
  # _were not_ created by the "VM Fusion - Development" team.
  statement {
    actions = [
      "*",
    ]
    condition {
      test = "StringNotEquals"
      values = [
        var.tags["Team"],
      ]
      variable = "aws:ResourceTag/Team"
    }
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "full_access_policy" {
  provider = aws.provisionassessment

  description = var.terraformer_role_description
  name        = var.terraformer_role_name
  policy      = data.aws_iam_policy_document.full_access_doc.json
}
