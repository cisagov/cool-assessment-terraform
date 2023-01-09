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
   variables (see [Inputs](#inputs) below for details).
1. Run the command `terraform init`.
1. Add all necessary permissions by running the command:

   ```console
   terraform apply -var-file=<workspace_name>.tfvars --target=aws_iam_policy.provisionassessment_policy --target=aws_iam_role_policy_attachment.provisionassessment_policy_attachment
   ```

1. Create all remaining Terraform infrastructure by running the command:

   ```console
   terraform apply -var-file=<workspace_name>.tfvars
   ```

## Examples ##

- [Using the Terraformer instance type](https://github.com/cisagov/cool-assessment-terraform/tree/develop/examples/use-terraformer-instance)

## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 3.38 |
| cloudinit | ~> 2.0 |
| null | ~> 3.0 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.38 |
| aws.dns\_sharedservices | ~> 3.38 |
| aws.organizationsreadonly | ~> 3.38 |
| aws.parameterstorereadonly | ~> 3.38 |
| aws.provisionassessment | ~> 3.38 |
| aws.provisionparameterstorereadrole | ~> 3.38 |
| aws.provisionsharedservices | ~> 3.38 |
| cloudinit | ~> 2.0 |
| null | ~> 3.0 |
| terraform | n/a |

## Modules ##

| Name | Source | Version |
|------|--------|---------|
| cw\_alarms\_assessor\_portal | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_debiandesktop | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_gophish | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_guacamole | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_kali | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_nessus | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_pentestportal | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_samba | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_teamserver | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_terraformer | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| cw\_alarms\_windows | github.com/cisagov/instance-cw-alarms-tf-module | n/a |
| email\_sending\_domain\_certreadrole | github.com/cisagov/cert-read-role-tf-module | n/a |
| guacamole\_certreadrole | github.com/cisagov/cert-read-role-tf-module | n/a |
| read\_terraform\_state | github.com/cisagov/terraform-state-read-role-tf-module | n/a |
| session\_manager | github.com/cisagov/session-manager-tf-module | n/a |
| vpc\_flow\_logs | trussworks/vpc-flow-logs/aws | ~>2.0 |

## Resources ##

| Name | Type |
|------|------|
| [aws_default_route_table.operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_ebs_volume.assessorportal_docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_ebs_volume.gophish_docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_ec2_transit_gateway_route.assessment_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table_association.association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_efs_access_point.access_point](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.persistent_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_eip.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.nat_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.assessorportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.samba](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.terraformer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.efs_mount_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.guacamole_parameterstorereadonly_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.nessus_parameterstorereadonly_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.provisionassessment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.provisionssmsessionmanager_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.terraformer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.assessorportal_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.debiandesktop_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.gophish_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.guacamole_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.guacamole_parameterstorereadonly_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.kali_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nessus_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nessus_parameterstorereadonly_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.pentestportal_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.samba_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.teamserver_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.terraformer_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.terraformer_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.windows_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.gophish_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.guacamole_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.kali_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.nessus_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.teamserver_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.terraformer_assume_delegated_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_assessorportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_samba](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_terraformer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment_windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ec2_read_only_policy_attachment_guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_assessorportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_samba](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_mount_policy_attachment_terraformer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.guacamole_parameterstorereadonly_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nessus_parameterstorereadonly_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.provisionassessment_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.provisionssmsessionmanager_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.read_only_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_assessorportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_samba](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_terraformer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_agent_policy_attachment_windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraformer_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.assessorportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.samba](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.terraformer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.operations_egress_to_anywhere_via_any_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_else_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_else_winrm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_1024_thru_3388](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_3390_thru_50049](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_50051_thru_65535](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_private_via_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_private_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_private_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_private_via_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.operations_ingress_from_private_via_winrm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_anywhere_via_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_anywhere_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_anywhere_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_cool_via_ipa_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_cool_via_tcp_ephemeral_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_cool_via_udp_ephemeral_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_local_vm_ips_via_all_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_operations_via_ephemeral_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_operations_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_operations_via_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_egress_to_operations_via_winrm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_anywhere_else_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_anywhere_else_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_anywhere_via_tcp_ephemeral_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_cool_vpn_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_local_vm_ips_via_all_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_operations_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_operations_mattermost_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_operations_smb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_from_operations_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_to_tg_attachment_via_ipa_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_ingress_to_tg_attachment_via_udp_ephemeral_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.cool_operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.cool_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.external_operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.external_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.assessorportal_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.debiandesktop_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.gophish_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.guacamole_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.guacamole_PTR](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.kali_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.nessus_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.pentestportal_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.samba_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.teamserver_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.terraformer_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.windows_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_vpc_association_authorization.assessment_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource |
| [aws_route53_zone.assessment_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.private_subnet_reverse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.assessment_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_route_table.private_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_route_table_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.assessorportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.cloudwatch_agent_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.cloudwatch_agent_endpoint_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.dynamodb_endpoint_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ec2_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ec2_endpoint_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs_mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.guacamole_accessible](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.pentestportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.s3_endpoint_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.scanner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.smb_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.smb_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssm_agent_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssm_agent_endpoint_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssm_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssm_endpoint_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sts_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sts_endpoint_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.terraformer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_nfs_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_nfs_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.assessorportal_egress_to_anywhere_via_http_and_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.debiandesktop_egress_to_anywhere_via_http_and_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.debiandesktop_egress_to_nessus_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_from_cloudwatch_agent_endpoint_client_to_cloudwatch_agent_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_from_ec2_endpoint_client_to_ec2_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_from_ssm_agent_endpoint_client_to_ssm_agent_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_from_ssm_endpoint_client_to_ssm_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_from_sts_endpoint_client_to_sts_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_to_dynamodb_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_to_s3_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_egress_to_cool_via_ipa_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_egress_to_hosts_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_egress_to_hosts_via_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.guacamole_ingress_from_trusted_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_assessorportal_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_debiandesktop_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_gophish_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_kali_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_nessus_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_pentestportal_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_teamserver_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_anywhere_to_windows_via_allowed_ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_cloudwatch_agent_endpoint_client_to_cloudwatch_agent_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_ec2_endpoint_client_to_ec2_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_guacamole_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_guacamole_via_vnc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_ssm_agent_endpoint_client_to_ssm_agent_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_ssm_endpoint_client_to_ssm_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_sts_endpoint_client_to_sts_endpoint_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_teamserver_to_gophish_via_smtp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_egress_to_nessus_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_egress_to_pentestportal_via_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_egress_to_teamserver_instances_via_5000_to_5999](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_egress_to_teamserver_via_imaps_and_cs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_egress_to_windows_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_ingress_from_teamserver_instances_via_5000_to_5999](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.kali_ingress_from_windows_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nessus_ingress_from_debiandesktop_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nessus_ingress_from_kali_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.nessus_ingress_from_windows_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.pentestportal_egress_to_anywhere_via_http_and_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.pentestportal_ingress_from_kali_via_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.pentestportal_ingress_from_windows_via_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.scanner_egress_to_anywhere_via_any_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.scanner_ingress_from_anywhere_via_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.smb_client_egress_to_smb_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.smb_server_ingress_from_smb_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teamserver_egress_to_gophish_via_587](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teamserver_egress_to_kali_instances_via_5000_to_5999](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teamserver_ingress_from_kali_instances_via_5000_to_5999](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teamserver_ingress_from_kali_via_imaps_and_cs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.terraformer_egress_anywhere_via_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.terraformer_egress_anywhere_via_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.terraformer_egress_anywhere_via_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.terraformer_egress_to_operations_via_winrm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.windows_egress_to_kali_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.windows_egress_to_nessus_via_web_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.windows_egress_to_pentestportal_via_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.windows_ingress_from_kali_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.operations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_volume_attachment.assessorportal_docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.gophish_docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_vpc.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_endpoint.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
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
| [aws_ami.assessorportal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.debiandesktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.gophish](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.guacamole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.nessus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.samba](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.terraformer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_default_tags.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.ec2_service_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.efs_mount_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gophish_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.guacamole_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.guacamole_parameterstore_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.guacamole_parameterstorereadonly_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kali_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nessus_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nessus_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nessus_parameterstorereadonly_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.provisionassessment_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.provisionssmsessionmanager_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.teamserver_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.terraformer_assume_delegated_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.terraformer_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.terraformer_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.users_account_assume_role_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.cool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_ssm_parameter.samba_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vnc_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [cloudinit_config.assessorportal_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.debiandesktop_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.gophish_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.guacamole_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.kali_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.nessus_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.pentestportal_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.samba_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.teamserver_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.terraformer_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [terraform_remote_state.dns_certboto](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.dynamic_assessment](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.images](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.images_parameterstore](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.master](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.sharedservices](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.sharedservices_networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.terraform](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| assessment\_account\_name | The name of the AWS account for this assessment (e.g. "env0"). | `string` | n/a | yes |
| assessmentfindingsbucketwrite\_sharedservices\_policy\_description | The description to associate with the IAM policy that allows assumption of the role in the Shared Services account that is allowed to write to the assessment findings bucket. | `string` | `"Allows assumption of the role in the Shared Services account that is allowed to write to the assessment findings bucket."` | no |
| assessmentfindingsbucketwrite\_sharedservices\_policy\_name | The name to assign the IAM policy that allows assumption of the role in the Shared Services account that is allowed to write to the assessment findings bucket. | `string` | `"SharedServices-AssumeAssessmentFindingsBucketWrite"` | no |
| assessor\_account\_role\_arn | The ARN of an IAM role that can be assumed to create, delete, and modify AWS resources in a separate assessor-owned AWS account. | `string` | `"arn:aws:iam::123456789012:role/Allow_It"` | no |
| aws\_availability\_zone | The AWS availability zone to deploy into (e.g. a, b, c, etc.) | `string` | `"a"` | no |
| aws\_region | The AWS region where the non-global resources for this assessment are to be provisioned (e.g. "us-east-1"). | `string` | `"us-east-1"` | no |
| cert\_bucket\_name | The name of the AWS S3 bucket where certificates are stored. | `string` | `"cisa-cool-certificates"` | no |
| cool\_domain | The domain where the COOL resources reside (e.g. "cool.cyber.dhs.gov"). | `string` | `"cool.cyber.dhs.gov"` | no |
| dns\_ttl | The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing. | `number` | `60` | no |
| efs\_access\_point\_gid | The group ID that should be used for file-system access to the EFS share (e.g. 2048).  Note that this value should match the GID of any group given ownership of the EFS share mount point. | `number` | `2048` | no |
| efs\_access\_point\_root\_directory | The non-root path to use as the root directory for the AWS EFS access point that controls EFS access for assessment data sharing. | `string` | `"/assessment_share"` | no |
| efs\_access\_point\_uid | The user ID that should be used for file-system access to the EFS share (e.g. 2048).  Note that this value should match the UID of any user given ownership of the EFS share mount point. | `number` | `2048` | no |
| efs\_users\_group\_name | The name of the POSIX group that should have ownership of a mounted EFS share (e.g. "efs\_users"). | `string` | `"efs_users"` | no |
| email\_sending\_domains | The list of domains to send emails from within the assessment environment (e.g. [ "example.com" ]).  Teamserver and Gophish instances will be deployed with each sequential domain in the list, so teamserver0 and gophish0 will get the first domain, teamserver1 and gophish1 will get the second domain, and so on.  If there are more Teamserver or Gophish instances than email-sending domains, the domains in the list will be reused in a wrap-around fashion. For example, if there are three Teamservers and only two email-sending domains, teamserver0 will get the first domain, teamserver1 will get the second domain, and teamserver2 will wrap-around back to using the first domain.  Note that all letters in this variable must be lowercase or else an error will be displayed. | `list(string)` | ```[ "example.com" ]``` | no |
| findings\_data\_bucket\_name | The name of the AWS S3 bucket where findings data is to be written.  The default value is not a valid string for a bucket name, so findings data cannot be written to any bucket unless a value is specified. | `string` | `""` | no |
| guac\_connection\_setup\_path | The full path to the dbinit directory where initialization files must be stored in order to work properly. (e.g. "/var/guacamole/dbinit") | `string` | `"/var/guacamole/dbinit"` | no |
| inbound\_ports\_allowed | An object specifying the ports allowed inbound (from anywhere) to the various instance types (e.g. {"assessorportal" : [], "debiandesktop" : [], "egressassess" : [], "gophish" : [], "kali": [{"protocol": "tcp", "from\_port": 443, "to\_port": 443}, {"protocol": "tcp", "from\_port": 9000, "to\_port": 9009}], "nessus" : [], "pentestportal" : [], "samba" : [], "teamserver" : [], "terraformer" : [], "windows" : [], }). | ```object({ assessorportal = list(object({ protocol = string, from_port = number, to_port = number })), debiandesktop = list(object({ protocol = string, from_port = number, to_port = number })), egressassess = list(object({ protocol = string, from_port = number, to_port = number })), gophish = list(object({ protocol = string, from_port = number, to_port = number })), kali = list(object({ protocol = string, from_port = number, to_port = number })), nessus = list(object({ protocol = string, from_port = number, to_port = number })), pentestportal = list(object({ protocol = string, from_port = number, to_port = number })), samba = list(object({ protocol = string, from_port = number, to_port = number })), teamserver = list(object({ protocol = string, from_port = number, to_port = number })), terraformer = list(object({ protocol = string, from_port = number, to_port = number })), windows = list(object({ protocol = string, from_port = number, to_port = number })), })``` | ```{ "assessorportal": [], "debiandesktop": [], "egressassess": [], "gophish": [], "kali": [], "nessus": [], "pentestportal": [], "samba": [], "teamserver": [], "terraformer": [], "windows": [] }``` | no |
| nessus\_activation\_codes | The list of Nessus activation codes (e.g. ["AAAA-BBBB-CCCC-DDDD"]). The number of codes in this list should match the number of Nessus instances defined in operations\_instance\_counts. | `list(string)` | `[]` | no |
| operations\_instance\_counts | A map specifying how many instances of each type should be created in the operations subnet (e.g. { "assessorportal" : 0, "debiandesktop" : 0, "egressassess" : 0,"gophish" : 0, "kali": 1, "nessus" : 0, "pentestportal" : 0, "samba" : 0, "teamserver" : 0, "terraformer" : 0, "windows" : 1, }). | ```object({ assessorportal = number, debiandesktop = number, egressassess = number, gophish = number, kali = number, nessus = number, pentestportal = number, samba = number, teamserver = number, terraformer = number, windows = number })``` | ```{ "assessorportal": 0, "debiandesktop": 0, "egressassess": 0, "gophish": 0, "kali": 1, "nessus": 0, "pentestportal": 0, "samba": 0, "teamserver": 0, "terraformer": 0, "windows": 1 }``` | no |
| operations\_subnet\_cidr\_block | The operations subnet CIDR block for this assessment (e.g. "10.10.0.0/24"). | `string` | n/a | yes |
| private\_domain | The local domain to use for this assessment (e.g. "env0"). If not provided, `local.private_domain` will be set to the base of the assessment account name.  For example, if the account name is "env0 (Staging)", `local.private_domain` will default to "env0".  Note that `local.private_domain` should be used in place of `var.private_domain` throughout this project. | `string` | `""` | no |
| private\_subnet\_cidr\_blocks | The list of private subnet CIDR blocks for this assessment (e.g. ["10.10.1.0/24", "10.10.2.0/24"]). | `list(string)` | n/a | yes |
| provisionaccount\_role\_name | The name of the IAM role that allows sufficient permissions to provision all AWS resources in the assessment account. | `string` | `"ProvisionAccount"` | no |
| provisionassessment\_policy\_description | The description to associate with the IAM policy that allows provisioning of the resources required in the assessment account. | `string` | `"Allows provisioning of the resources required in the assessment account."` | no |
| provisionassessment\_policy\_name | The name to assign the IAM policy that allows provisioning of the resources required in the assessment account. | `string` | `"ProvisionAssessment"` | no |
| provisionssmsessionmanager\_policy\_description | The description to associate with the IAM policy that allows sufficient permissions to provision the SSM Document resource and set up SSM session logging in this assessment account. | `string` | `"Allows sufficient permissions to provision the SSM Document resource and set up SSM session logging in this assessment account."` | no |
| provisionssmsessionmanager\_policy\_name | The name to assign the IAM policy that allows sufficient permissions to provision the SSM Document resource and set up SSM session logging in this assessment account. | `string` | `"ProvisionSSMSessionManager"` | no |
| read\_terraform\_state\_role\_name | The name to assign the IAM role (as well as the corresponding policy) that allows read-only access to the cool-assessment-terraform state in the S3 bucket where Terraform state is stored.  The %s in this name will be replaced by the value of the assessment\_account\_name variable. | `string` | `"ReadCoolAssessmentTerraformTerraformState-%s"` | no |
| session\_cloudwatch\_log\_group\_name | The name of the log group into which session logs are to be uploaded. | `string` | `"/ssm/session-logs"` | no |
| ssm\_key\_nessus\_admin\_password | The AWS SSM Parameter Store parameter that contains the password of the Nessus admin user (e.g. "/nessus/assessment/admin\_password"). | `string` | `"/nessus/assessment/admin_password"` | no |
| ssm\_key\_nessus\_admin\_username | The AWS SSM Parameter Store parameter that contains the username of the Nessus admin user (e.g. "/nessus/assessment/admin\_username"). | `string` | `"/nessus/assessment/admin_username"` | no |
| ssm\_key\_samba\_username | The AWS SSM Parameter Store parameter that contains the username of the Samba user (e.g. "/samba/username"). | `string` | `"/samba/username"` | no |
| ssm\_key\_vnc\_username | The AWS SSM Parameter Store parameter that contains the username of the VNC user (e.g. "/vnc/username"). | `string` | `"/vnc/username"` | no |
| tags | Tags to apply to all AWS resources created | `map(string)` | `{}` | no |
| terraformer\_role\_description | The description to associate with the IAM role (and policy) that allows Terraformer instances to create appropriate AWS resources in this account. | `string` | `"Allows Terraformer instances to create appropriate AWS resources in this account."` | no |
| terraformer\_role\_name | The name to assign the IAM role (and policy) that allows Terraformer instances to create appropriate AWS resources in this account. | `string` | `"Terraformer"` | no |
| vpc\_cidr\_block | The CIDR block to use this assessment's VPC (e.g. "10.224.0.0/21"). | `string` | n/a | yes |
| windows\_with\_docker | A boolean to control the instance type used when creating Windows instances to allow Docker Desktop support. Windows instances require the `metal` instance type to run Docker Desktop because of nested virtualization, but if Docker Desktop is not needed then other instance types are fine. | `bool` | `false` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| assessment\_private\_zone | The private DNS zone for this assessment. |
| assessor\_portal\_instance\_profile | The instance profile for the Assessor Portal instances. |
| assessor\_portal\_instances | The Assessor Portal instances. |
| assessor\_portal\_security\_group | The security group for the Assessor Portal instances. |
| aws\_region | The AWS region where this assessment environment lives. |
| certificate\_bucket\_name | The name of the S3 bucket where certificate information is stored for this assessment. |
| cloudwatch\_agent\_endpoint\_client\_security\_group | A security group for any instances that run the AWS CloudWatch agent.  This security groups allows such instances to communicate with the VPC endpoints that are required by the AWS CloudWatch agent. |
| debian\_desktop\_instance\_profile | The instance profile for the Debian desktop instances. |
| debian\_desktop\_instances | The Debian desktop instances. |
| debian\_desktop\_security\_group | The security group for the Debian desktop instances. |
| dynamodb\_endpoint\_client\_security\_group | A security group for any instances that wish to communicate with the DynamoDB VPC endpoint. |
| ec2\_endpoint\_client\_security\_group | A security group for any instances that wish to communicate with the EC2 VPC endpoint. |
| efs\_access\_points | The access points to control file-system access to the EFS file share. |
| efs\_client\_security\_group | A security group that should be applied to all instances that will mount the EFS file share. |
| efs\_mount\_targets | The mount targets for the EFS file share. |
| egressassess\_instance\_profile | The instance profile for the Egress-Assess instances. |
| egressassess\_instances | The Egress-Assess instances. |
| egressassess\_security\_group | The security group for the Egress-Assess instances. |
| email\_sending\_domain\_certreadroles | The IAM roles that allow for reading the certificate for each email-sending domain. |
| gophish\_instance\_profiles | The instance profiles for the Gophish instances. |
| gophish\_instances | The Gophish instances. |
| gophish\_security\_group | The security group for the Gophish instances. |
| guacamole\_accessible\_security\_group | A security group that should be applied to all instances that are to be accessible from Guacamole. |
| guacamole\_server | The AWS EC2 instance hosting Guacamole. |
| kali\_instance\_profile | The instance profile for the Kali instances. |
| kali\_instances | The Kali instances. |
| kali\_security\_group | The security group for the Kali instances. |
| nessus\_instance\_profile | The instance profile for the Nessus instances. |
| nessus\_instances | The Nessus instances. |
| nessus\_security\_group | The security group for the Nessus instances. |
| operations\_subnet | The operations subnet. |
| operations\_subnet\_acl | The access control list (ACL) for the operations subnet. |
| pentest\_portal\_instance\_profile | The instance profile for the Pentest Portal instances. |
| pentest\_portal\_instances | The Pentest Portal instances. |
| pentest\_portal\_security\_group | The security group for the Pentest Portal instances. |
| private\_subnet\_acls | The access control lists (ACLs) for the private subnets. |
| private\_subnet\_cidr\_blocks | The private subnet CIDR blocks.  These are used to index into the private\_subnets and efs\_mount\_targets outputs. |
| private\_subnet\_nat\_gateway | The NAT gateway for the private subnets. |
| private\_subnets | The private subnets. |
| read\_terraform\_state\_module | The IAM policies and role that allow read-only access to the cool-assessment-terraform workspace-specific state in the Terraform state bucket. |
| remote\_desktop\_url | The URL of the remote desktop gateway (Guacamole) for this assessment. |
| s3\_endpoint\_client\_security\_group | A security group for any instances that wish to communicate with the S3 VPC endpoint. |
| samba\_client\_security\_group | The security group that should be applied to all instance types that wish to mount the Samba file share being served by the Samba file share server instances. |
| samba\_instance\_profile | The instance profile for the Samba file share server instances. |
| samba\_instances | The Samba file share server instances. |
| samba\_server\_security\_group | The security group for the Samba file share server instances. |
| scanner\_security\_group | A security group that should be applied to all instance types that perform scanning.  This security group allows egress to anywhere as well as ingress from anywhere via ICMP. |
| ssm\_agent\_endpoint\_client\_security\_group | A security group for any instances that run the AWS SSM agent.  This security group allows such instances to communicate with the VPC endpoints that are required by the AWS SSM agent. |
| ssm\_endpoint\_client\_security\_group | A security group for any instances that wish to communicate with the SSM VPC endpoint. |
| ssm\_session\_role | An IAM role that allows creation of SSM SessionManager sessions to any EC2 instance in this account. |
| sts\_endpoint\_client\_security\_group | A security group for any instances that wish to communicate with the STS VPC endpoint. |
| teamserver\_instance\_profiles | The instance profiles for the Teamserver instances. |
| teamserver\_instances | The Teamserver instances. |
| teamserver\_security\_group | The security group for the Teamserver instances. |
| terraformer\_instances | The Terraformer instances. |
| terraformer\_security\_group | The security group for the Terraformer instances. |
| vpc | The VPC for this assessment environment. |
| vpn\_server\_cidr\_block | The CIDR block for the COOL VPN. |
| windows\_instance\_profile | The instance profile for the Windows instances. |
| windows\_instances | The Windows instances. |
| windows\_security\_group | The security group for the Windows instances. |

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
