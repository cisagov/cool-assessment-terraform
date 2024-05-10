# Create a role that allows the instance to read its certs from S3.
module "guacamole_certreadrole" {
  source = "github.com/cisagov/cert-read-role-tf-module"

  providers = {
    aws = aws.provisioncertreadrole
  }

  account_ids      = [local.assessment_account_id]
  cert_bucket_name = var.cert_bucket_name
  hostname         = local.guacamole_fqdn
}

# Create the IAM instance profile for the Guacamole EC2 server instance

# The instance profile to be used
resource "aws_iam_instance_profile" "guacamole" {
  provider = aws.provisionassessment

  name = "guacamole_instance_profile_${terraform.workspace}"
  role = aws_iam_role.guacamole_instance_role.name
}

# The instance role
resource "aws_iam_role" "guacamole_instance_role" {
  provider = aws.provisionassessment

  assume_role_policy = data.aws_iam_policy_document.ec2_service_assume_role_doc.json
  name               = "guacamole_instance_role_${terraform.workspace}"
}

resource "aws_iam_role_policy" "guacamole_assume_delegated_role_policy" {
  provider = aws.provisionassessment

  name   = "assume_delegated_role_policy"
  policy = data.aws_iam_policy_document.guacamole_assume_delegated_role_policy_doc.json
  role   = aws_iam_role.guacamole_instance_role.id
}

# Attach the EC2 read-only policy to this role.  This policy is
# required by the cisagov/guacscanner Docker image
# (https://github.com/cisagov/guacscanner-docker)
# that is part of the Guacamole composition.
resource "aws_iam_role_policy_attachment" "ec2_read_only_policy_attachment_guacamole" {
  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.guacamole_instance_role.id
}

# Attach the CloudWatch Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment_guacamole" {
  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.guacamole_instance_role.id
}

# Attach the SSM Agent policy to this role as well
resource "aws_iam_role_policy_attachment" "ssm_agent_policy_attachment_guacamole" {
  provider = aws.provisionassessment

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.guacamole_instance_role.id
}

################################
# Define the role policies below
################################

# Allow the Guacamole instance to assume the necessary roles:
#  - To read the Guacamole certificates from an S3 bucket
#  - To read the VNC-related data from the SSM Parameter Store
data "aws_iam_policy_document" "guacamole_assume_delegated_role_policy_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    resources = [
      module.guacamole_certreadrole.role.arn,
      aws_iam_role.guacamole_parameterstorereadonly_role.arn
    ]
    effect = "Allow"
  }
}
