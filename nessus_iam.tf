# Create the IAM instance profile for the Nessus EC2 server instance

# The instance profile to be used
resource "aws_iam_instance_profile" "nessus" {
  provider = aws.provisionassessment

  name = "nessus_instance_profile_${terraform.workspace}"
  role = aws_iam_role.nessus_instance_role.name
}

# The instance role
resource "aws_iam_role" "nessus_instance_role" {
  provider = aws.provisionassessment

  name               = "nessus_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.nessus_assume_role_policy_doc.json
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_nessus" {
  provider = aws.provisionassessment

  role       = aws_iam_role.nessus_instance_role.id
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
