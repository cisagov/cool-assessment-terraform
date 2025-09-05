# ------------------------------------------------------------------------------
# Create the IAM policy that allows all of the permissions necessary
# to stop, start, and reboot any of the Operations instances.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "reboot_operations_instances_policy_doc" {
  count = length(local.operations_instances_arns) > 0 ? 1 : 0

  statement {
    actions = [
      "ec2:RebootInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
    ]

    resources = local.operations_instances_arns
  }

  # This permission allows assessors to check the status of instances (to see if
  # they are stopped or running).  Note that this permission cannot be scoped to
  # specific resources, so it must apply to all resources.
  statement {
    actions = [
      "ec2:DescribeInstanceStatus",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "reboot_operations_instances_policy" {
  count = length(local.operations_instances_arns) > 0 ? 1 : 0

  provider = aws.provisionassessment

  description = var.reboot_operations_instances_policy_description
  name        = var.reboot_operations_instances_policy_name
  policy      = data.aws_iam_policy_document.reboot_operations_instances_policy_doc[0].json
}
