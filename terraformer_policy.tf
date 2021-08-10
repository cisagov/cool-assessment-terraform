# Create the IAM policy for the Terraformer EC2 server instances that
# allows them to create/destroy.modify the appropriate (and _only_ the
# appropriate) resources in this account.

data "aws_iam_policy_document" "terraformer_doc" {
  provider = aws.provisionassessment

  # Allow the user to do _anything_ with resources that _were not_
  # created by the "VM Fusion - Development" team.
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

resource "aws_iam_policy" "terraformer_policy" {
  provider = aws.provisionassessment

  description = var.terraformer_role_description
  name        = var.terraformer_role_name
  policy      = data.aws_iam_policy_document.terraformer_doc.json
}
