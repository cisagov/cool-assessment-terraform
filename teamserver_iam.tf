# Create the IAM instance profile for the Teamserver EC2 server
# instances

# The instance profile to be used
resource "aws_iam_instance_profile" "teamserver" {
  provider = aws.provisionassessment

  name = "teamserver_instance_profile_${terraform.workspace}"
  role = aws_iam_role.teamserver_instance_role.name
}

# The instance role
resource "aws_iam_role" "teamserver_instance_role" {
  provider = aws.provisionassessment

  name = "teamserver_instance_role_${terraform.workspace}"
  # We can just reuse the kali assume role policy here.  If we created
  # a teamserver-specific one it would be identical.
  assume_role_policy = data.aws_iam_policy_document.kali_assume_role_policy_doc.json
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_teamserver" {
  provider = aws.provisionassessment

  role       = aws_iam_role.teamserver_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach the SSM Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_teamserver" {
  provider = aws.provisionassessment

  role       = aws_iam_role.teamserver_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach a policy that allows the Teamserver instances to mount and
# write to the EFS
resource "aws_iam_role_policy_attachment" "efs_mount_policy_attachment_teamserver" {
  provider = aws.provisionassessment

  role = aws_iam_role.teamserver_instance_role.id
  # We can just reuse the kali policy here.  If we created a
  # teamserver-specific one it would be identical.
  policy_arn = aws_iam_policy.kali_efs_mount_policy.arn
}
