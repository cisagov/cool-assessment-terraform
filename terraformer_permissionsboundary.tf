# Create the IAM permissions boundary policy for the Terraformer EC2 instances.
# This policy allows full AWS permissions except for the following:
# * Deny modification of any resources tagged by the team that deploys this
#   root module, with some exceptions (detailed below).
# * Deny use of the Guacamole, Samba, and Terraformer instance roles.
# * Deny modification of CloudFormation resources created by Control Tower.
# * Deny modification or deletion of this permissions boundary policy.
# * Deny removal of this permissions boundary policy from users and roles.
# * Deny creation of users or roles that do not have this permissions boundary.
# * Deny applying any other permission boundary policies to users or roles.

data "aws_iam_policy_document" "terraformer_permissions_boundary_policy_doc" {
  provider = aws.provisionassessment

  # Allow read-only access to EC2 resources tagged by the team that deploys
  # this root module.
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:Get*",
      "ec2:List*",
    ]
    condition {
      test = "StringEquals"
      values = [
        lookup(var.tags, "Team", "Undefined Team tag value"),
      ]
      variable = "aws:ResourceTag/Team"
    }
    resources = [
      "*",
    ]
    sid = "AllowReadingEC2ResourcesTaggedByTeam"
  }

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
    sid = "DenyModifyingResourcesTaggedByTeam"
  }

  # Deny use of the Guacamole, Samba, and Terraformer instance roles.
  statement {
    actions = [
      "iam:PassRole",
    ]
    effect = "Deny"
    resources = [
      aws_iam_role.guacamole_instance_role.arn,
      aws_iam_role.samba_instance_role.arn,
      aws_iam_role.terraformer_instance_role.arn,
    ]
    sid = "DenyPassingProtectedInstanceRoles"
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
    sid = "AllowUsingCOOLAMIKMSKey"
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
      # The private subnet where Guacamole and Terraformer instances
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
    sid = "AllowLaunchingOpsInstancesAndAddingRemovingSGsFromInstances"
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
    sid = "AllowCreatingSGsAndRoutingTablesInAssessmentVPC"
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
    sid = "AllowManagingOperationsNACL"
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
    sid = "AllowAssociatingDisassociatingRouteTables"
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
    sid = "AllowModifyingS3Endpoint"
  }

  # Don't allow Terraformer instances to touch the CloudFormation foo put in
  # place by Control Tower.  CloudFormation resources do not accept tags and
  # thus cannot be tagged with a team tag, which is why this statement is needed
  # (an earlier statement prevents modification of any resources tagged by the
  # team that deploys this root module).
  statement {
    actions = [
      "cloudformation:*",
    ]
    effect = "Deny"
    resources = [
      "arn:aws:cloudformation:*:${local.assessment_account_id}:stack/StackSet-AWSControlTower*/*",
    ]
    sid = "DenyModifyingControlTowerStacks"
  }

  # Deny modification or deletion of this permissions boundary policy.
  statement {
    actions = [
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
    ]
    effect = "Deny"
    resources = [
      "arn:aws:iam::${local.assessment_account_id}:policy/${var.terraformer_permissions_boundary_policy_name}",
    ]
    sid = "DenyModifyingBoundaryPolicy"
  }

  # Deny deletion of permissions boundary from users or roles.
  statement {
    actions = [
      "iam:DeleteRolePermissionsBoundary",
      "iam:DeleteUserPermissionsBoundary",
    ]
    condition {
      test = "StringEquals"
      values = [
        "arn:aws:iam::${local.assessment_account_id}:policy/${var.terraformer_permissions_boundary_policy_name}",
      ]
      variable = "iam:PermissionsBoundary"
    }
    effect = "Deny"
    resources = [
      "*",
    ]
    sid = "DenyRemovingBoundaryFromUsersAndRoles"
  }

  # Deny creation of users or roles that do not have this permissions boundary.
  statement {
    actions = [
      "iam:CreateRole",
      "iam:CreateUser",
    ]
    condition {
      test = "StringNotEquals"
      values = [
        "arn:aws:iam::${local.assessment_account_id}:policy/${var.terraformer_permissions_boundary_policy_name}",
      ]
      variable = "iam:PermissionsBoundary"
    }
    effect = "Deny"
    resources = [
      "*",
    ]
    sid = "DenyCreatingUsersAndRolesWithoutBoundary"
  }

  # Deny applying any other permission boundary policies to users or roles.
  statement {
    actions = [
      "iam:PutRolePermissionsBoundary",
      "iam:PutUserPermissionsBoundary",
    ]
    condition {
      test = "StringNotEquals"
      values = [
        "arn:aws:iam::${local.assessment_account_id}:policy/${var.terraformer_permissions_boundary_policy_name}",
      ]
      variable = "iam:PermissionsBoundary"
    }
    effect = "Deny"
    resources = [
      "*",
    ]
    sid = "DenyApplyingOtherBoundaryPolicies"
  }
}

resource "aws_iam_policy" "terraformer_permissions_boundary_policy" {
  provider = aws.provisionassessment

  description = var.terraformer_permissions_boundary_policy_description
  name        = var.terraformer_permissions_boundary_policy_name
  policy      = data.aws_iam_policy_document.terraformer_permissions_boundary_policy_doc.json
}
