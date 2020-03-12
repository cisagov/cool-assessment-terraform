# Create the IAM instance profile for the Kali EC2 server instance

# The instance profile to be used
resource "aws_iam_instance_profile" "kali" {
  provider = aws.provisionassessment

  name = "kali_instance_profile_${terraform.workspace}"
  role = aws_iam_role.kali_instance_role.name
}

# The instance role
resource "aws_iam_role" "kali_instance_role" {
  provider = aws.provisionassessment

  name               = "kali_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.kali_assume_role_policy_doc.json
}

# TODO: Determine if needed:
# resource "aws_iam_role_policy" "kali_assume_delegated_role_policy" {
#   provider = aws.provisionassessment
#
#   name   = "assume_delegated_role_policy"
#   role   = aws_iam_role.kali_instance_role.id
#   policy = data.aws_iam_policy_document.kali_assume_delegated_role_policy_doc.json
# }

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_kali" {
  provider = aws.provisionassessment

  role       = aws_iam_role.kali_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

################################
# Define the role policies below
################################

data "aws_iam_policy_document" "kali_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

# TODO: Determine if needed:
# # Allow the Kali instance to assume the necessary roles:
# data "aws_iam_policy_document" "kali_assume_delegated_role_policy_doc" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     resources = [
#     ]
#     effect = "Allow"
#   }
# }
