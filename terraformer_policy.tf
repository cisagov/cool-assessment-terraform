# Create the IAM policy for the Terraformer EC2 server instances that
# allows full access to create/destroy new resources in this account
# and create/modify/destroy existing resources that _are not_ tagged
# as being created by the team that deploys this root module.
#
# Also allow sufficient permissions to launch instances in the
# operations subnet and use the existing security groups.

data "aws_iam_policy_document" "terraformer_policy_doc" {
  provider = aws.provisionassessment

  # Allow full access to new resources and existing resources that
  # _are not_ tagged as being created by the team that deploys this
  # root module.
  statement {
    actions = [
      "*",
    ]
    condition {
      test = "StringNotEquals"
      values = [
        var.tags["Team"],
      ]
      variable = "aws:ResourceTag/Team"
    }
    resources = [
      "*",
    ]
  }

  # Allow use of the KMS key used to encrypt COOL AMIs.
  statement {
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]
    resources = [
      data.terraform_remote_state.images.outputs.ami_kms_key.arn
    ]
  }

  # Allow the launching of new instances in the operations subnet,
  # using the existing security groups.
  #
  # Also allow the ModifyNetworkInterfaceAttribute permission when our
  # existing security groups are involved.  This is necessary when the
  # Terraformer instance is used to add or remove security groups from
  # an instance.
  statement {
    actions = [
      "ec2:RunInstances",
      "ec2:ModifyNetworkInterfaceAttribute",
    ]
    resources = [
      # Subnets.  The ModifyNetworkInterfaceAttribute doesn't care
      # about these resources, but they don't hurt anything being
      # here.
      aws_subnet.operations.arn,
      # The private subnet where guacamole and Terraformer instances
      # currently live.
      aws_subnet.private[var.private_subnet_cidr_blocks[0]].arn,
      # Security groups
      aws_security_group.assessorportal.arn,
      aws_security_group.cloudwatch_and_ssm_agent.arn,
      aws_security_group.debiandesktop.arn,
      aws_security_group.efs_client.arn,
      aws_security_group.gophish.arn,
      aws_security_group.guacamole_accessible.arn,
      aws_security_group.kali.arn,
      aws_security_group.nessus.arn,
      aws_security_group.pentestportal.arn,
      aws_security_group.scanner.arn,
      aws_security_group.teamserver.arn,
    ]
  }

  # Allow Terraformer instances to create new security groups in the
  # assessment VPC.
  statement {
    actions = [
      "ec2:CreateSecurityGroup",
    ]
    resources = [
      aws_vpc.assessment.arn,
    ]
  }

  # Allow Terraformer instances to create, modify, and delete network
  # ACLs for the operations subnet.
  statement {
    actions = [
      "ec2:CreateNetworkAclEntry",
      "ec2:DeleteNetworkAclEntry",
      "ec2:ReplaceNetworkAclEntry",
    ]
    resources = [
      aws_network_acl.operations.arn,
    ]
  }
}

resource "aws_iam_policy" "terraformer_policy" {
  provider = aws.provisionassessment

  description = var.terraformer_role_description
  name        = var.terraformer_role_name
  policy      = data.aws_iam_policy_document.terraformer_policy_doc.json
}
