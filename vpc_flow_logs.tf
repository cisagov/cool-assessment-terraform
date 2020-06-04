# IAM assume role policy document for the role we're creating
data "aws_iam_policy_document" "vpc_flow_log_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

# The IAM role for flow logs
resource "aws_iam_role" "vpc_flow_log" {
  provider = aws.provisionassessment

  name = "vpc_flow_log_${local.assessment_workspace_name}"

  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_assume_role.json
}

# IAM policy document that that allows some permissions for flow logs.
# This will be applied to the role we are creating.
data "aws_iam_policy_document" "vpc_flow_log" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "*",
    ]
  }
}

# The IAM role policy for the flow log role
resource "aws_iam_role_policy" "vpc_flow_log" {
  provider = aws.provisionassessment

  name = "vpc_flow_log_${local.assessment_workspace_name}"
  role = aws_iam_role.vpc_flow_log.id

  policy = data.aws_iam_policy_document.vpc_flow_log.json
}

# The flow log group
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  provider = aws.provisionassessment

  name = "vpc_flow_log_${local.assessment_workspace_name}"
}

# The flow logs
resource "aws_flow_log" "vpc_flow_log" {
  provider = aws.provisionassessment

  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
  vpc_id          = aws_vpc.assessment.id
  traffic_type    = "ALL"
}
