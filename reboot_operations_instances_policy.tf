# ------------------------------------------------------------------------------
# Create the IAM policy that allows all of the permissions necessary
# to reboot any of the Operations instances.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "reboot_operations_instances_policy_doc" {
  count = length(local.operations_instances_arns) > 0 ? 1 : 0

  statement {
    actions = [
      "ec2:RebootInstances",
    ]

    resources = local.operations_instances_arns
  }
}

resource "aws_iam_policy" "reboot_operations_instances_policy" {
  count = length(local.operations_instances_arns) > 0 ? 1 : 0

  provider = aws.provisionassessment

  description = var.reboot_operations_instances_policy_description
  name        = var.reboot_operations_instances_policy_name
  policy      = data.aws_iam_policy_document.reboot_operations_instances_policy_doc[0].json
}
