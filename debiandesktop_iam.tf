# Create the IAM instance profile for the "Debian desktop" EC2 instances

# The instance profile to be used
resource "aws_iam_instance_profile" "debiandesktop" {
  provider = aws.provisionassessment

  name = "debiandesktop_instance_profile_${terraform.workspace}"
  role = aws_iam_role.debiandesktop_instance_role.name
}

# The instance role
resource "aws_iam_role" "debiandesktop_instance_role" {
  provider = aws.provisionassessment

  name               = "debiandesktop_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ec2_service_assume_role_doc.json
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_debiandesktop" {
  provider = aws.provisionassessment

  role       = aws_iam_role.debiandesktop_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach the SSM Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_debiandesktop" {
  provider = aws.provisionassessment

  role       = aws_iam_role.debiandesktop_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach a policy that allows the Debian desktop instances to mount and
# write to the EFS
resource "aws_iam_role_policy_attachment" "efs_mount_policy_attachment_debiandesktop" {
  provider = aws.provisionassessment

  role       = aws_iam_role.debiandesktop_instance_role.id
  policy_arn = aws_iam_policy.efs_mount_policy.arn
}
