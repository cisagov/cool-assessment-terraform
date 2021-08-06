# Create the IAM instance profile for the Gophish EC2 server
# instances

# The instance profile to be used
resource "aws_iam_instance_profile" "gophish" {
  provider = aws.provisionassessment

  name = "gophish_instance_profile_${terraform.workspace}"
  role = aws_iam_role.gophish_instance_role.name
}

# The instance role
resource "aws_iam_role" "gophish_instance_role" {
  provider = aws.provisionassessment

  name               = "gophish_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ec2_service_assume_role_doc.json
}

resource "aws_iam_role_policy" "gophish_assume_delegated_role_policy" {
  provider = aws.provisionassessment

  name   = "assume_delegated_role_policy"
  role   = aws_iam_role.gophish_instance_role.id
  policy = data.aws_iam_policy_document.gophish_assume_delegated_role_policy_doc.json
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_gophish" {
  provider = aws.provisionassessment

  role       = aws_iam_role.gophish_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach the SSM Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_gophish" {
  provider = aws.provisionassessment

  role       = aws_iam_role.gophish_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach a policy that allows the Gophish instances to mount and
# write to the EFS
resource "aws_iam_role_policy_attachment" "efs_mount_policy_attachment_gophish" {
  provider = aws.provisionassessment

  role       = aws_iam_role.gophish_instance_role.id
  policy_arn = aws_iam_policy.efs_mount_policy.arn
}

################################
# Define the role policies below
################################

# Allow the Gophish instance to assume the necessary role to read
# its email-sending domain certificates from an S3 bucket.
data "aws_iam_policy_document" "gophish_assume_delegated_role_policy_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    effect = "Allow"
    resources = [
      module.email_sending_domain_certreadrole.role.arn,
    ]
  }
}
