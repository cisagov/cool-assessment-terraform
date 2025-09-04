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

  assume_role_policy = data.aws_iam_policy_document.ec2_service_assume_role_doc.json
  name               = "debiandesktop_instance_role_${terraform.workspace}"
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_debiandesktop" {
  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.debiandesktop_instance_role.id
}

# Attach the SSM Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_debiandesktop" {
  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.debiandesktop_instance_role.id
}

# Attach a policy that allows the Debian desktop instances to mount and
# write to the EFS
resource "aws_iam_role_policy_attachment" "efs_mount_policy_attachment_debiandesktop" {
  provider = aws.provisionassessment

  policy_arn = aws_iam_policy.efs_mount_policy.arn
  role       = aws_iam_role.debiandesktop_instance_role.id
}

# Attach the policy that allows stopping, starting, and rebooting of Operations
# instances to this instance role
resource "aws_iam_role_policy_attachment" "reboot_operations_instances_policy_attachment_debiandesktop" {
  count = length(local.operations_instances_arns) > 0 ? 1 : 0

  provider = aws.provisionassessment

  policy_arn = aws_iam_policy.reboot_operations_instances_policy[0].arn
  role       = aws_iam_role.debiandesktop_instance_role.id
}
