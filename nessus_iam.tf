# Create the IAM instance profile for the Nessus EC2 server instance

# The instance profile to be used
resource "aws_iam_instance_profile" "nessus" {
  count    = lookup(var.operations_instance_counts, "nessus", 0) > 0 ? 1 : 0
  provider = aws.provisionassessment

  name = "nessus_instance_profile_${terraform.workspace}"
  role = aws_iam_role.nessus_instance_role[count.index].name
}

# The instance role
resource "aws_iam_role" "nessus_instance_role" {
  count    = lookup(var.operations_instance_counts, "nessus", 0) > 0 ? 1 : 0
  provider = aws.provisionassessment

  name               = "nessus_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.nessus_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "nessus_assume_delegated_role_policy" {
  count    = lookup(var.operations_instance_counts, "nessus", 0) > 0 ? 1 : 0
  provider = aws.provisionassessment

  name   = "nessus_assume_delegated_role_policy"
  role   = aws_iam_role.nessus_instance_role[count.index].id
  policy = data.aws_iam_policy_document.nessus_assume_delegated_role_policy_doc[count.index].json
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_nessus" {
  count    = lookup(var.operations_instance_counts, "nessus", 0) > 0 ? 1 : 0
  provider = aws.provisionassessment

  role       = aws_iam_role.nessus_instance_role[count.index].id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

################################
# Define the role policies below
################################

data "aws_iam_policy_document" "nessus_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

# Allow the Nessus instance to assume the role needed
# to read the Nessus-related data from the SSM Parameter Store
data "aws_iam_policy_document" "nessus_assume_delegated_role_policy_doc" {
  count = lookup(var.operations_instance_counts, "nessus", 0) > 0 ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      aws_iam_role.nessus_parameterstorereadonly_role[count.index].arn
    ]
    effect = "Allow"
  }
}
