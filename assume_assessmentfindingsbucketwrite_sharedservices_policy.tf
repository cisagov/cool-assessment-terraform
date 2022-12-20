# ------------------------------------------------------------------------------
# Create the IAM policy that allows assumption of the role in the Shared
# Services account that allows writing to the assessment findings bucket.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "assume_assessmentfindingsbucketwrite_sharedservices_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    resources = [
      data.terraform_remote_state.sharedservices.outputs.assessment_findings_write_role.arn,
    ]
  }
}

resource "aws_iam_policy" "assume_assessmentfindingsbucketwrite_sharedservices_policy" {
  provider = aws.provisionassessment

  description = var.assessmentfindingsbucketwrite_sharedservices_policy_description
  name        = var.assessmentfindingsbucketwrite_sharedservices_policy_name
  policy      = data.aws_iam_policy_document.assume_assessmentfindingsbucketwrite_sharedservices_doc.json
}
