# cool-assessment-terraform #

[![GitHub Build Status](https://github.com/cisagov/cool-assessment-terraform/workflows/build/badge.svg)](https://github.com/cisagov/cool-assessment-terraform/actions)

This project is used to create an operational assessment environment in
the COOL environment.

## Pre-requisites ##

- [Terraform](https://www.terraform.io/) installed on your system.
- An accessible AWS S3 bucket to store Terraform state
  (specified in [`backend.tf`](backend.tf)).
- An accessible AWS DynamoDB database to store the Terraform state lock
  (specified in [`backend.tf`](backend.tf)).
- Access to all of the Terraform remote states specified in
  [`remote_states.tf`](remote_states.tf).
- Accept the terms for any AWS Marketplace subscriptions to be used by the
  operations instances in your assessment environment (must be done in
  the AWS account hosting the assessment environment):
  - [Kali Linux](https://console.aws.amazon.com/marketplace/home?#/subscriptions/U1VCU0NSSVBUSU9OQEBAOGI3ZmRmZTMtOGNkNS00M2NjLThlNWUtNGUwZTdmNDEzOWQ1)
- Access to AWS AMIs for [Guacamole](https://github.com/cisagov/guacamole-packer)
  and any other operations instance types used in your assessment.
- OpenSSL server certificate and private key for the Guacamole instance
  in your assessment environment, stored in an accessible AWS S3 bucket;
  this can be easily created via
  [certboto-docker](https://github.com/cisagov/certboto-docker)
  or a similar tool.
- A Terraform [variables](variables.tf) file customized for your
  assessment environment, for example:

  ```console
  assessment_account_name = "env0"
  private_domain          = "env0"

  vpc_cidr_block               = "10.224.0.0/21"
  operations_subnet_cidr_block = "10.224.0.0/24"
  private_subnet_cidr_blocks   = ["10.224.1.0/24", "10.224.2.0/24"]

  tags = {
    Team        = "VM Fusion - Development"
    Application = "COOL - env0 Account"
    Workspace   = "env0"
  }
  ```

## Building the Terraform-based infrastructure ##

1. Create a Terraform workspace (if you haven't already done so) for
   your assessment by running `terraform workspace new <workspace_name>`.
1. Create a `<workspace_name>.tfvars` file with all of the required
   variables (see [Inputs](#Inputs) below for details).
1. Run the command `terraform init`.
1. Add all necessary permissions by running the command:

   ```console
   terraform apply -var-file=<workspace_name>.tfvars --target=aws_iam_policy.provisionassessment_policy --target=aws_iam_role_policy_attachment.provisionassessment_policy_attachment
   ```

1. Create all remaining Terraform infrastructure by running the command:

   ```console
   terraform apply -var-file=<workspace_name>.tfvars
   ```

## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 0.12.0 |
| aws | ~> 3.0 |
| cloudinit | ~> 2.0 |
| null | ~> 3.0 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| aws.dns\_sharedservices | ~> 3.0 |
| aws.organizationsreadonly | ~> 3.0 |
| aws.provisionassessment | ~> 3.0 |
| aws.provisionparameterstorereadrole | ~> 3.0 |
| aws.provisionsharedservices | ~> 3.0 |
| cloudinit | ~> 2.0 |
| null | ~> 3.0 |
| terraform | n/a |

## Modules ##

| Name | Source | Version |
|------|--------|---------|
| guacamole\_certreadrole | github.com/cisagov/cert-read-role-tf-module |  |
| run\_shell\_ssm\_document | gazoakley/session-manager-settings/aws |  |
| teamserver\_certreadrole | github.com/cisagov/cert-read-role-tf-module |  |
| vpc\_flow\_logs | trussworks/vpc-flow-logs/aws | >=2.0.0, <2.1.0 |

## Resources ##

| Name | Type |
|------|------|
| [aws_default_route_table.operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_ec2_transit_gateway_route.assessment_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table_association.association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_efs_file_system.persistent_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_eip.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.efs_mount_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.nessus_parameterstorereadonly_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.provisionassessment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssmsession_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.vnc_parameterstorereadonly_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.debiandesktop_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.gophish_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.guacamole_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.kali_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nessus_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nessus_parameterstorereadonly_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.pentestportal_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ssmsession_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.teamserver_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vnc_parameterstorereadonly_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.guacamole_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.nessus_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.teamserver_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nessus_parameterstorereadonly_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.provisionassessment_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_gophics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssmsession_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vnc_parameterstorereadonly_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_network_acl.operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.operations_egress_to_anywhere_via_any_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_1024_thru_3388](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_3390_thru_5900](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_50051_thru_65535](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_5902_thru_50049](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_private_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_private_via_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_anywhere_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_cool_via_ephemeral_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_cool_via_ipa_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_operations_via_ephemeral_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_operations_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_operations_via_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_anywhere_via_ephemeral_ports_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_anywhere_via_ephemeral_ports_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_cool_vpn_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_operations_via_ephemeral_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_operations_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_to_tg_attachment_via_ipa_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.cool_operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.cool_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.external_operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.debiandesktop_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.gophish_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.guacamole_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.guacamole_PTR](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.kali_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.nessus_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.pentestportal_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.teamserver_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_vpc_association_authorization.assessment_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource |
| [aws_route53_zone.assessment_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.private_subnet_reverse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.assessment_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_route_table.private_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_route_table_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.cloudwatch_and_ssm_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs_mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.guacamole_accessible](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.scanner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.agent_egress_to_cloudwatch_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.agent_egress_to_ssm_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_nfs_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_nfs_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.debiandesktop_egress_to_anywhere_via_http_and_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.debiandesktop_egress_to_nessus_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_egress_to_cool_via_ipa_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_egress_to_hosts_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_egress_to_hosts_via_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_egress_to_s3_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_egress_to_sts_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_ingress_from_trusted_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_debiandesktop_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_gophish_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_kali_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_nessus_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_pentestportal_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_teamserver_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_debiandesktop_to_cloudwatch_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_debiandesktop_to_ssm_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_gophish_to_cloudwatch_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_gophish_to_ssm_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_guacamole_to_cloudwatch_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_guacamole_to_ssm_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_guacamole_to_sts_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_guacamole_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_guacamole_via_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_kali_to_cloudwatch_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_kali_to_ssm_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_nessus_to_cloudwatch_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_nessus_to_ssm_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_nessus_to_sts_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_pentestportal_to_cloudwatch_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_pentestportal_to_ssm_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_teamserver_to_cloudwatch_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_teamserver_to_gophish_via_smtp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_teamserver_to_ssm_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_teamserver_to_sts_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_egress_to_nessus_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_egress_to_pentestportal_via_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_egress_to_teamserver_via_imaps_and_cs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nessus_ingress_from_debiandesktop_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nessus_ingress_from_kali_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.pentestportal_egress_to_anywhere_via_http_and_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.pentestportal_ingress_from_kali_via_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.scanner_egress_to_anywhere_via_any_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.scanner_ingress_from_anywhere_via_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teamserver_egress_to_gophish_via_587](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teamserver_egress_to_s3_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teamserver_egress_to_sts_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teamserver_ingress_from_kali_via_imaps_and_cs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_endpoint.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ec2messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssmmessages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.s3_operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.s3_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_subnet_association.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [aws_vpc_endpoint_subnet_association.ec2messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [aws_vpc_endpoint_subnet_association.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [aws_vpc_endpoint_subnet_association.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [aws_vpc_endpoint_subnet_association.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [aws_vpc_endpoint_subnet_association.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [aws_vpc_endpoint_subnet_association.ssmmessages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [aws_vpc_endpoint_subnet_association.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource |
| [null_resource.break_association_with_default_route_table](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_ami.debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ec2_service_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.efs_mount_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.guacamole_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nessus_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nessus_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nessus_parameterstorereadonly_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.provisionassessment_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssmsession_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.teamserver_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.users_account_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vnc_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vnc_parameterstorereadonly_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.cool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [cloudinit_config.gophish_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.guacamole_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.kali_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.nessus_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.teamserver_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [terraform_remote_state.dns_certboto](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.dynamic_assessment](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.images](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.images_parameterstore](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.master](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.sharedservices](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.sharedservices_networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| assessment\_account\_name | The name of the AWS account for this assessment (e.g. "env0"). | `string` | n/a | yes |
| aws\_availability\_zone | The AWS availability zone to deploy into (e.g. a, b, c, etc.) | `string` | `"a"` | no |
| aws\_region | The AWS region where the non-global resources for this assessment are to be provisioned (e.g. "us-east-1"). | `string` | `"us-east-1"` | no |
| cert\_bucket\_name | The name of the AWS S3 bucket where certificates are stored. | `string` | `"cisa-cool-certificates"` | no |
| cool\_domain | The domain where the COOL resources reside (e.g. "cool.cyber.dhs.gov"). | `string` | `"cool.cyber.dhs.gov"` | no |
| dns\_ttl | The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing. | `number` | `60` | no |
| email\_sending\_domain | The domain to send emails from within the assessment environment (e.g. "example.com"). | `string` | `"example.com"` | no |
| guac\_connection\_setup\_path | The full path to the dbinit directory where initialization files must be stored in order to work properly. (e.g. "/var/guacamole/dbinit") | `string` | `"/var/guacamole/dbinit"` | no |
| inbound\_ports\_allowed | A map specifying the ports allowed inbound (from anywhere) to the various instance types (e.g. {"kali": [{"protocol": "tcp", "from_port": 8000, "to_port": 8999}]}).  The currently-supported keys are: "debiandesktop", "gophish", "kali", "nessus", "pentestportal", and "teamserver". | `map(list(object({ protocol = string, from_port = number, to_port = number })))` | `{"debiandesktop": [], "gophish": [{"from_port": 25, "protocol": "tcp", "to_port": 25}, {"from_port": 80, "protocol": "tcp", "to_port": 80},{"from_port": 443, "protocol": "tcp", "to_port": 443}, {"from_port": 587, "protocol": "tcp", "to_port": 587}], "kali": [{"from_port": 8000, "protocol": "tcp", "to_port": 8999}], "nessus": [], "pentestportal": [], "teamserver": [{"from_port": 25, "protocol": "tcp", "to_port": 25}, {"from_port": 53, "protocol": "tcp", "to_port": 53}, {"from_port": 80, "protocol": "tcp", "to_port": 80}, {"from_port": 443, "protocol": "tcp", "to_port": 443}, {"from_port": 587, "protocol": "tcp", "to_port": 587}, {"from_port": 53, "protocol": "udp", "to_port": 53}, {"from_port": 8080, "protocol": "udp", "to_port": 8080}, {"from_port": 8000, "protocol": "tcp", "to_port": 8999}]}` | no |
| nessus\_activation\_codes | The list of Nessus activation codes (e.g. ["AAAA-BBBB-CCCC-DDDD"]). The number of codes in this list should match the number of Nessus instances defined in operations\_instance\_counts. | `list(string)` | `[]` | no |
| operations\_instance\_counts | A map specifying how many instances of each type should be created in the operations subnet (e.g. { "kali": 1 }).  The currently-supported instance keys are: ["debiandesktop", "gophish", "kali", "nessus", "pentestportal", "teamserver"]. | `map(number)` | `{"kali": 1}` | no |
| operations\_subnet\_cidr\_block | The operations subnet CIDR block for this assessment (e.g. "10.10.0.0/24"). | `string` | n/a | yes |
| private\_domain | The local domain to use for this assessment (e.g. "env0"). If not provided, `local.private_domain` will be set to the base of the assessment account name.  For example, if the account name is "env0 (Staging)", `local.private_domain` will default to "env0".  Note that `local.private_domain` should be used in place of `var.private_domain` throughout this project. | `string` | `""` | no |
| private\_subnet\_cidr\_blocks | The list of private subnet CIDR blocks for this assessment (e.g. ["10.10.1.0/24", "10.10.2.0/24"]). | `list(string)` | n/a | yes |
| provisionaccount\_role\_name | The name of the IAM role that allows sufficient permissions to provision all AWS resources in the assessment account. | `string` | `"ProvisionAccount"` | no |
| provisionassessment\_policy\_description | The description to associate with the IAM policy that allows provisioning of the resources required in the assessment account. | `string` | `"Allows provisioning of the resources required in the assessment account."` | no |
| provisionassessment\_policy\_name | The name to assign the IAM policy that allows provisioning of the resources required in the assessment account. | `string` | `"ProvisionAssessment"` | no |
| ssm\_key\_nessus\_admin\_password | The AWS SSM Parameter Store parameter that contains the password of the Nessus admin user (e.g. "/nessus/assessment/admin\_password"). | `string` | `"/nessus/assessment/admin_password"` | no |
| ssm\_key\_nessus\_admin\_username | The AWS SSM Parameter Store parameter that contains the username of the Nessus admin user (e.g. "/nessus/assessment/admin\_username"). | `string` | `"/nessus/assessment/admin_username"` | no |
| ssm\_key\_vnc\_password | The AWS SSM Parameter Store parameter that contains the password needed to connect to the TBD instance via VNC (e.g. "/vnc/password") | `string` | `"/vnc/password"` | no |
| ssm\_key\_vnc\_user\_private\_ssh\_key | The AWS SSM Parameter Store parameter that contains the private SSH key of the VNC user on the TBD instance (e.g. "/vnc/ssh/rsa\_private\_key") | `string` | `"/vnc/ssh/rsa_private_key"` | no |
| ssm\_key\_vnc\_username | The AWS SSM Parameter Store parameter that contains the username of the VNC user on the TBD instance (e.g. "/vnc/username") | `string` | `"/vnc/username"` | no |
| ssmsession\_role\_description | The description to associate with the IAM role (and policy) that allows creation of SSM SessionManager sessions to any EC2 instance in this account. | `string` | `"Allows creation of SSM SessionManager sessions to any EC2 instance in this account."` | no |
| ssmsession\_role\_name | The name to assign the IAM role (and policy) that allows creation of SSM SessionManager sessions to any EC2 instance in this account. | `string` | `"StartStopSSMSession"` | no |
| tags | Tags to apply to all AWS resources created | `map(string)` | `{}` | no |
| vpc\_cidr\_block | The CIDR block to use this assessment's VPC (e.g. "10.224.0.0/21"). | `string` | n/a | yes |

## Outputs ##

| Name | Description |
|------|-------------|
| guacamole\_server | The AWS EC2 instance hosting guacamole. |
| remote\_desktop\_url | The URL of the remote desktop gateway (Guacamole) for this assessment. |
| ssm\_session\_role | An IAM role that allows creation of SSM SessionManager sessions to any EC2 instance in this account. |

## Notes ##

Running `pre-commit` requires running `terraform init` in every directory that
contains Terraform code. In this repository, this is only the main directory.

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
