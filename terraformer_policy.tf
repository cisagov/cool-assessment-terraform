# Create the IAM policy for the Terraformer EC2 server instances that
# allows full access to create/destroy new resources in this account
# and create/modify/destroy existing resources that _are not_ tagged
# as being created by the team that deploys this root module (there are
# some exceptions to this rule, see below for details).
#
# Also allow sufficient permissions to launch instances in the
# operations subnet and use the existing security groups.

data "aws_iam_policy_document" "terraformer_policy_doc" {
  provider = aws.provisionassessment

  # Allow modification of any resources, except those tagged by the team that
  # deploys this root module.
  statement {
    actions = [
      "*",
    ]
    condition {
      test = "StringNotEquals"
      values = [
        lookup(var.tags, "Team", "Undefined Team tag value"),
      ]
      variable = "aws:ResourceTag/Team"
    }
    resources = [
      "*",
    ]
  }

  # Allow use of the KMS key used to encrypt COOL AMIs.  This explicit "allow"
  # is necessary because the key is tagged with the "Team" tag.
  statement {
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]
    resources = [
      data.terraform_remote_state.images.outputs.ami_kms_key.arn
    ]
  }

  # Allow the launching of new instances in the operations subnet and the
  # first private subnet, using the existing security groups.
  #
  # Also allow the ModifyNetworkInterfaceAttribute permission when our
  # existing security groups are involved.  This is necessary when the
  # Terraformer instance is used to add or remove security groups from
  # an instance.
  #
  # This explicit "allow" is necessary because the resources below are tagged
  # with the "Team" tag.
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
      aws_security_group.cloudwatch_agent_endpoint_client.arn,
      aws_security_group.debiandesktop.arn,
      aws_security_group.dynamodb_endpoint_client.arn,
      aws_security_group.ec2_endpoint_client.arn,
      aws_security_group.efs_client.arn,
      aws_security_group.gophish.arn,
      aws_security_group.guacamole_accessible.arn,
      aws_security_group.kali.arn,
      aws_security_group.nessus.arn,
      aws_security_group.pentestportal.arn,
      aws_security_group.s3_endpoint_client.arn,
      aws_security_group.scanner.arn,
      aws_security_group.smb_client.arn,
      aws_security_group.ssm_agent_endpoint_client.arn,
      aws_security_group.ssm_endpoint_client.arn,
      aws_security_group.sts_endpoint_client.arn,
      aws_security_group.teamserver.arn,
      aws_security_group.windows.arn,
    ]
  }

  # Allow Terraformer instances to create new security groups and routing tables
  # and manage VPC peering connections in the assessment VPC.  This explicit
  # "allow" is necessary because the VPC is tagged with the "Team" tag.
  statement {
    actions = [
      "ec2:AcceptVpcPeeringConnection",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateVpcPeeringConnection",
      "ec2:DeleteVpcPeeringConnection",
    ]
    resources = [
      aws_vpc.assessment.arn,
    ]
  }

  # Allow Terraformer instances to create, modify, and delete network
  # ACLs for the operations subnet.  This explicit "allow" is necessary
  # because the Operations NACL is tagged with the "Team" tag.
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

  # Allow Terraformer instances to disassociate the default operations and
  # private routing tables and associate additional routing tables with the
  # first private subnet.  This is needed so that custom routing tables can
  # be used.  This explicit "allow" is necessary because the resources below
  # are tagged with the "Team" tag.
  statement {
    actions = [
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
    ]
    resources = [
      aws_default_route_table.operations.arn,
      aws_route_table.private_route_table.arn,
      aws_subnet.private[var.private_subnet_cidr_blocks[0]].arn,
    ]
  }

  # Allow Terraformer instances to modify the S3 VPC gateway endpoint.  This
  # is needed so that the endpoint can be added to a new, custom route table.
  # This explicit "allow" is necessary because the S3 endpoint is tagged with
  # the "Team" tag.
  statement {
    actions = [
      "ec2:ModifyVpcEndpoint",
    ]
    resources = [
      aws_vpc_endpoint.s3.arn,
    ]
  }
}

resource "aws_iam_policy" "terraformer_policy" {
  provider = aws.provisionassessment

  description = var.terraformer_role_description
  name        = var.terraformer_role_name
  policy      = data.aws_iam_policy_document.terraformer_policy_doc.json
}
