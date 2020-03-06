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

  name               = "guacamole_instance_role_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.guacamole_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "guacamole_assume_delegated_role_policy" {
  provider = aws.provisionassessment

  name   = "assume_delegated_role_policy"
  role   = aws_iam_role.guacamole_instance_role.id
  policy = data.aws_iam_policy_document.guacamole_assume_delegated_role_policy_doc.json
}

################################
# Define the role policies below
################################

data "aws_iam_policy_document" "guacamole_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

# TODO: When adding assessment instances (e.g. Kali), add ARN allowed to
# read VNC creds from SSM Parameter Store to "resources" below
data "aws_iam_policy_document" "guacamole_assume_delegated_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "${module.guacamole_certreadrole.role.arn}"
    ]
    effect = "Allow"
  }
}
