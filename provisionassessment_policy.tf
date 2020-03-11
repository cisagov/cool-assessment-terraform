# ------------------------------------------------------------------------------
# Create the IAM policy that allows all of the permissions necessary
# to provision the resources required in the assessment account.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "provisionassessment_policy_doc" {
  statement {
    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateDhcpOptions",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateDhcpOptions",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateNetworkAcl",
      "ec2:CreateNetworkAclEntry",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateTransitGatewayVpcAttachment",
      "ec2:CreateVpc",
      "ec2:DeleteDhcpOptions",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNatGateway",
      "ec2:DeleteNetworkAcl",
      "ec2:DeleteNetworkAclEntry",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteTransitGatewayVpcAttachment",
      "ec2:DeleteVpc",
      "ec2:Describe*",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateRouteTable",
      "ec2:DisassociateVpcCidrBlock",
      "ec2:GetTransitGatewayRouteTableAssociations",
      "ec2:GetTransitGatewayRouteTablePropagations",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyTransitGatewayVpcAttachment",
      "ec2:ModifyVpcAttribute",
      "ec2:ReleaseAddress",
      "ec2:ReplaceNetworkAclAssociation",
      "ec2:ReplaceNetworkAclEntry",
      "ec2:ReplaceRoute",
      "ec2:ReplaceRouteTableAssociation",
      "ec2:ReportInstanceStatus",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RunInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    resources = [
      data.terraform_remote_state.images.outputs.ami_kms_key.arn
    ]
  }

  statement {
    actions = [
      "route53:AssociateVPCWithHostedZone",
      "route53:DisassociateVPCFromHostedZone",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${local.cool_dns_private_zone.zone_id}"
    ]
  }
}

resource "aws_iam_policy" "provisionassessment_policy" {
  provider = aws.provisionassessment

  description = var.provisionassessment_policy_description
  name        = var.provisionassessment_policy_name
  policy      = data.aws_iam_policy_document.provisionassessment_policy_doc.json
}
