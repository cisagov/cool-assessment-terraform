# Create the IAM instance profile for the Gophish EC2 server
# instances

# The instance profiles to be used
resource "aws_iam_instance_profile" "gophish" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  provider = aws.provisionassessment

  name = "gophish${count.index}_instance_profile_${terraform.workspace}"
  role = aws_iam_role.gophish_instance_role[count.index].name
}

# The instance roles
resource "aws_iam_role" "gophish_instance_role" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  provider = aws.provisionassessment

  assume_role_policy = data.aws_iam_policy_document.ec2_service_assume_role_doc.json
  name               = "gophish${count.index}_instance_role_${terraform.workspace}"
}

resource "aws_iam_role_policy" "gophish_assume_delegated_role_policy" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  provider = aws.provisionassessment

  name   = "assume_delegated_role_policy"
  policy = data.aws_iam_policy_document.gophish_assume_delegated_role_policy_doc[count.index].json
  role   = aws_iam_role.gophish_instance_role[count.index].id
}

# Attach the CloudWatch Agent policy to these roles as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_gophish" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.gophish_instance_role[count.index].id
}

# Attach the SSM Agent policy to these roles as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_gophish" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.gophish_instance_role[count.index].id
}

# Attach a policy that allows the Gophish instances to mount and
# write to the EFS
resource "aws_iam_role_policy_attachment" "efs_mount_policy_attachment_gophish" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  provider = aws.provisionassessment

  policy_arn = aws_iam_policy.efs_mount_policy.arn
  role       = aws_iam_role.gophish_instance_role[count.index].id
}

################################
# Define the role policies below
################################

# Allow each Gophish instance to assume the necessary role to read
# its email-sending domain certificate from an S3 bucket.
data "aws_iam_policy_document" "gophish_assume_delegated_role_policy_doc" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

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
