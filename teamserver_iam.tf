# Create a role that allows the instance to read its certs from S3.
module "teamserver_certreadrole" {
  source = "github.com/cisagov/cert-read-role-tf-module"

  providers = {
    aws = aws.provisioncertreadrole
  }

  account_ids      = [local.assessment_account_id]
  cert_bucket_name = var.cert_bucket_name
  hostname         = "*.${var.email_sending_domain}"
}

# Create the IAM instance profile for the Teamserver EC2 server
# instance

# The instance profile to be used
resource "aws_iam_instance_profile" "teamserver" {
  provider = aws.provisionassessment

  name = "teamserver_instance_profile_${terraform.workspace}"
  role = aws_iam_role.teamserver_instance_role.name
}

# The instance role
resource "aws_iam_role" "teamserver_instance_role" {
  provider = aws.provisionassessment

  name               = "teamserver_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.teamserver_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "teamserver_assume_delegated_role_policy" {
  provider = aws.provisionassessment

  name   = "assume_delegated_role_policy"
  role   = aws_iam_role.teamserver_instance_role.id
  policy = data.aws_iam_policy_document.teamserver_assume_delegated_role_policy_doc.json
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

# Attach a policy that allows the Teamserver instances to mount and write to
# the EFS
resource "aws_iam_role_policy_attachment" "efs_mount_policy_attachment_teamserver" {
  provider = aws.provisionassessment

  role       = aws_iam_role.teamserver_instance_role.id
  policy_arn = aws_iam_policy.teamserver_efs_mount_policy.arn
}

################################
# Define the role policies below
################################

data "aws_iam_policy_document" "teamserver_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# The policy doc that allows the teamserver instances to mount and
# write to the EFS
data "aws_iam_policy_document" "teamserver_efs_mount_policy_doc" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite"
    ]
    effect = "Allow"
    resources = [
      # Allow mounting of the EFS mount target in the first private
      # subnet
      aws_efs_mount_target.target[var.private_subnet_cidr_blocks[0]].file_system_arn
    ]
  }
}
resource "aws_iam_policy" "teamserver_efs_mount_policy" {
  provider = aws.provisionassessment

  policy = data.aws_iam_policy_document.teamserver_efs_mount_policy_doc.json
}

# Allow the teamserver instance to assume the necessary role to read
# the teamserver certificates from an S3 bucket.
data "aws_iam_policy_document" "teamserver_assume_delegated_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    resources = [
      module.teamserver_certreadrole.role.arn,
    ]
  }
}
