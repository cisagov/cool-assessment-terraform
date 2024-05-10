# Create the IAM instance profile for the Egress-Assess EC2 instances

# The instance profile to be used
resource "aws_iam_instance_profile" "egressassess" {
  provider = aws.provisionassessment

  name = "egressassess_instance_profile_${terraform.workspace}"
  role = aws_iam_role.egressassess_instance_role.name
}

# The instance role
resource "aws_iam_role" "egressassess_instance_role" {
  provider = aws.provisionassessment

  assume_role_policy = data.aws_iam_policy_document.ec2_service_assume_role_doc.json
  name               = "egressassess_instance_role_${terraform.workspace}"
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_egressassess" {
  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.egressassess_instance_role.id
}

# Attach the SSM Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_egressassess" {
  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.egressassess_instance_role.id
}
