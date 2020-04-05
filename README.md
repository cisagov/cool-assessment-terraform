# cool-assessment-terraform #

[![GitHub Build Status](https://github.com/cisagov/cool-assessment-terraform/workflows/build/badge.svg)](https://github.com/cisagov/cool-assessment-terraform/actions)

This project is used to create an operational assessment environment in
the COOL environment.

## Pre-requisites ##

- [Terraform](https://www.terraform.io/) installed on your system.
- An accessible AWS S3 bucket to store Terraform state
  (specified [here](backend.tf)).
- An accessible AWS DynamoDB database to store the Terraform state lock
  (specified [here](backend.tf)).
- Access to all of the Terraform remote states specified in
  [the remote states file](remote_states.tf).
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

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| assessment_account_name | The name of the AWS account for this assessment (e.g. "env0"). | string | | yes |
| aws_availability_zone | The AWS availability zone to deploy into (e.g. a, b, c, etc.) | string | `a` | no |
| aws_region | The AWS region to deploy into (e.g. us-east-1). | string | `us-east-1` | no |
| cert_bucket_name | The name of the AWS S3 bucket where certificates are stored. | string | `cisa-cool-certificates` | no |
| cool_domain | The domain where the COOL resources reside (e.g. "cool.cyber.dhs.gov"). | string | `cool.cyber.dhs.gov` | no |
| guac_connection_setup_path | The full path to the dbinit directory where initialization files must be stored in order to work properly (e.g. "/var/guacamole/dbinit"). | string | `/var/guacamole/dbinit` | no |
| operations_instance_counts | A map specifying how many instances of each type should be created in the operations subnet (e.g. { "kali": 1 }).  The currently-supported instance keys are: ["kali"]. | map(number) | `{ "kali": 1 }` | no |
| operations_subnet_cidr_block | The operations subnet CIDR block for this assessment (e.g. "10.10.0.0/24"). | string | | yes |
| operations_subnet_inbound_tcp_ports_allowed | The list of TCP ports allowed inbound (from anywhere) to the operations subnet (e.g. ["80", "443"]). | list(string) | `["80", "443"]` | no |
| operations_subnet_inbound_udp_ports_allowed | The list of UDP ports allowed inbound (from anywhere) to the operations subnet (e.g. ["53", "8080"]). | list(string) | `[]` | no |
| private_domain | The local domain to use for this assessment (e.g. "env0"). If not provided, `local.private_domain` will be set to the base of the assessment account name.  For example, if the account name is "env0 (Staging)", `local.private_domain` will default to "env0".  Note that `local.private_domain` should be used in place of `var.private_domain` throughout this project. | string | Assessment account name base | no |
| private_subnet_cidr_blocks | The list of private subnet CIDR blocks for this assessment (e.g. ["10.10.1.0/24", "10.10.2.0/24"]). | list(string) | | yes |
| provisionaccount_role_name | The name of the IAM role that allows sufficient permissions to provision all AWS resources in the assessment account. | string | `ProvisionAccount` | no |
| provisionassessment_policy_description | The description to associate with the IAM policy that allows provisioning of the resources required in the assessment account. | string | `Allows provisioning of the resources required in the assessment account` | no |
| provisionassessment_policy_name | The name to assign the IAM policy that allows provisioning of the resources required in the assessment account. | string | `ProvisionAssessment` | no |
| ssm_key_vnc_password | The AWS SSM Parameter Store parameter that contains the password needed to connect to the TBD instance via VNC (e.g. "/vnc/password"). | string | `/vnc/password` | no |
| ssm_key_vnc_username | The AWS SSM Parameter Store parameter that contains the username of the VNC user on the TBD instance (e.g. "/vnc/username"). | string | `/vnc/username` | no |
| ssm_key_vnc_user_private_ssh_key | The AWS SSM Parameter Store parameter that contains the private SSH key of the VNC user on the TBD instance (e.g. "/vnc/ssh/rsa_private_key". | string | `/vnc/ssh/rsa_private_key` | no |
| tags | Tags to apply to all AWS resources created | map(string) | `{}` | no |
| vpc_cidr_block | The CIDR block to use this assessment's VPC (e.g. "10.224.0.0/21"). | string | | yes |

## Outputs ##

| Name | Description |
|------|-------------|
| remote_desktop_url | The URL of the remote desktop gateway (Guacamole) for this assessment. |

## Contributing ##

We welcome contributions!  Please see [here](CONTRIBUTING.md) for
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
