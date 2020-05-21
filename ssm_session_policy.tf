# ------------------------------------------------------------------------------
# Create the IAM policy that allows creation of SSM SessionManager
# sessions to any EC2 instance in this account.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "ssmsession_doc" {
  provider = aws.provisionassessment

  # Allow the user to start a session
  statement {
    actions = [
      "ssm:SendCommand",
      "ssm:StartSession",
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ssm:*:*:document/AWS-StartSSHSession",
      "arn:aws:ssm:*:*:document/SSM-SessionManagerRunShell",
    ]
    condition {
      test     = "BoolIfExists"
      variable = "ssm:SessionDocumentAccessCheck"
      values = [
        true,
      ]
    }
  }

  # Allow the user to collect some information
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ssm:DescribeInstanceInformation",
      "ssm:DescribeInstanceProperties",
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
    ]
    resources = [
      "*",
    ]
  }

  # Allow the user to terminate his or her own sessions
  statement {
    actions = [
      "ssm:TerminateSession",
    ]
    resources = [
      "arn:aws:ssm:*:*:session/&{aws:username}-*",
    ]
  }
}

resource "aws_iam_policy" "ssmsession_policy" {
  provider = aws.provisionassessment

  description = var.ssmsession_role_description
  name        = var.ssmsession_role_name
  policy      = data.aws_iam_policy_document.ssmsession_doc.json
}
