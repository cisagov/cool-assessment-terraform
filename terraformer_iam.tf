# Create the IAM instance profile for the Terraformer EC2 server
# instances

# The instance profile to be used
resource "aws_iam_instance_profile" "terraformer" {
  provider = aws.provisionassessment

  name = "terraformer_instance_profile_${terraform.workspace}"
  role = aws_iam_role.terraformer_instance_role.name
}

# The instance role
resource "aws_iam_role" "terraformer_instance_role" {
  provider = aws.provisionassessment

  name               = "terraformer_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ec2_service_assume_role_doc.json
}

resource "aws_iam_role_policy" "terraformer_assume_delegated_role_policy" {
  provider = aws.provisionassessment

  name   = "terraformer_assume_delegated_role_policy"
  role   = aws_iam_role.terraformer_instance_role.id
  policy = data.aws_iam_policy_document.terraformer_assume_delegated_role_policy_doc.json
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_terraformer" {
  provider = aws.provisionassessment

  role       = aws_iam_role.terraformer_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach the SSM Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_terraformer" {
  provider = aws.provisionassessment

  role       = aws_iam_role.terraformer_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach a policy that allows the Terraformer instances to mount and
# write to the EFS
resource "aws_iam_role_policy_attachment" "efs_mount_policy_attachment_terraformer" {
  provider = aws.provisionassessment

  role       = aws_iam_role.terraformer_instance_role.id
  policy_arn = aws_iam_policy.efs_mount_policy.arn
}

################################
# Define the role policies below
################################

# Allow the Terraformer instance to assume the necessary role to
# create/destroy/modify AWS resources.
data "aws_iam_policy_document" "terraformer_assume_delegated_role_policy_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    effect = "Allow"
    resources = [
      aws_iam_role.terraformer_role.arn,
      module.read_terraform_state.role.arn,
      data.terraform_remote_state.master.outputs.organizationsreadonly_role.arn,
      aws_iam_role.gucamole_parameterstorereadonly_role.arn,
      var.assessor_account_role_arn,
    ]
  }
}
