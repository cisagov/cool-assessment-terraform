# cool-assessment-terraform #

[![GitHub Build Status](https://github.com/cisagov/cool-assessment-terraform/workflows/build/badge.svg)](https://github.com/cisagov/cool-assessment-terraform/actions)

This project is used to create an operational assessment environment in
the COOL environment.

## Building the Terraform-based infrastructure ##

Coming soon!

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| assessment_account_name | The name of the AWS account for this assessment (e.g. "env0"). | string | | yes |
| aws_availability_zone | The AWS availability zone to deploy into (e.g. a, b, c, etc.) | string | `a` | no |
| aws_region | The AWS region to deploy into (e.g. us-east-1). | string | `us-east-1` | no |
| cert_bucket_name | The name of the AWS S3 bucket where certificates are stored. | string | `cisa-cool-certificates` | no |
| cool_domain | The domain where the COOL resources reside (e.g. "cool.cyber.dhs.gov"). | string | `cool.cyber.dhs.gov` | no |
| guac_connection_name | The desired name of the Guacamole connection to the TBD instance. | string | `TBD` | no |
| guac_connection_setup_filename | The name of the file to create on the Guacamole instance containing SQL instructions to populate any desired Guacamole connections.  NOTE: Postgres processes these files alphabetically, so it's important to name this file so it runs after the file that defines the Guacamole tables and users ("00_initdb.sql"). | string | `01_setup_guac_connections.sql` | no |
| guac_connection_setup_path | The full path to the dbinit directory where <guac_connection_setup_filename> must be stored in order to work properly (e.g. "/var/guacamole/dbinit"). | string | `/var/guacamole/dbinit` | no |
| operations_subnet_cidr_block | The operations subnet CIDR block for this assessment (e.g. "10.10.0.0/24"). | string | | yes |
| operations_subnet_inbound_tcp_ports_allowed | The list of TCP ports allowed inbound (from anywhere) to the operations subnet (e.g. ["80", "443"]). | list(string) | `["80", "443"]` | no |
| private_domain | The local domain to use for this assessment (e.g. "env0"). | string | | yes |
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
| TBD | TBD |

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
