# Create the IAM instance profile for the Teamserver EC2 server
# instance

# The instance profiles to be used
resource "aws_iam_instance_profile" "teamserver" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)

  provider = aws.provisionassessment

  name = "teamserver${count.index}_instance_profile_${terraform.workspace}"
  role = aws_iam_role.teamserver_instance_role[count.index].name
}

# The instance roles
resource "aws_iam_role" "teamserver_instance_role" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)

  provider = aws.provisionassessment

  name               = "teamserver${count.index}_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ec2_service_assume_role_doc.json
}

resource "aws_iam_role_policy" "teamserver_assume_delegated_role_policy" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)

  provider = aws.provisionassessment

  name   = "assume_delegated_role_policy"
  role   = aws_iam_role.teamserver_instance_role[count.index].id
  policy = data.aws_iam_policy_document.teamserver_assume_delegated_role_policy_doc[count.index].json
}

# Attach the CloudWatch Agent policy to these roles as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_teamserver" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)

  provider = aws.provisionassessment

  role       = aws_iam_role.teamserver_instance_role[count.index].id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach the SSM Agent policy to these roles as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_teamserver" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)

  provider = aws.provisionassessment

  role       = aws_iam_role.teamserver_instance_role[count.index].id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach a policy that allows the Teamserver instances to mount and write to
# the EFS
resource "aws_iam_role_policy_attachment" "efs_mount_policy_attachment_teamserver" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)

  provider = aws.provisionassessment

  role       = aws_iam_role.teamserver_instance_role[count.index].id
  policy_arn = aws_iam_policy.efs_mount_policy.arn
}

################################
# Define the role policies below
################################

# Allow each Teamserver instance to assume the necessary role to read
# its email-sending domain certificate from an S3 bucket.
data "aws_iam_policy_document" "teamserver_assume_delegated_role_policy_doc" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    effect = "Allow"
    resources = [
      module.email_sending_domain_certreadrole[element(var.email_sending_domains, count.index)].role.arn,
    ]
  }
}
