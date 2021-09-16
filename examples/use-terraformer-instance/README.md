# Using the Terraform instance #

This example code shows how to use the Terraformer code to spin up a
new instance in the operations subnet of an existing assessment
environment already created by running `terraform apply` with the
[cisagov/cool-assessment-terraform](https://github.com/cisagov/cool-assessment-terraform)
root module.

## Requirements ##

No requirements.

## Providers ##

| Name | Version |
|------|---------|
| aws | n/a |
| aws.read\_organization\_information | n/a |
| cloudinit | n/a |
| terraform | n/a |

## Modules ##

No modules.

## Resources ##

| Name | Type |
|------|------|
| [aws_eip.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_route53_record.teamserver_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ami.teamserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_default_tags.assessment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_organizations_organization.cool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [cloudinit_config.teamserver_cloud_init_tasks](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [terraform_remote_state.cool_assessment_terraform](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_region | The AWS region where the non-global resources for this assessment are to be provisioned (e.g. "us-east-1"). | `string` | `"us-east-1"` | no |
| dns\_ttl | The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing. | `number` | `60` | no |
| email\_sending\_domain | The domain to send emails from within the assessment environment (e.g. "example.com"). | `string` | `"example.com"` | no |
| tags | Tags to apply to all AWS resources created | `map(string)` | `{}` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| teamserver | The Teamserver instance. |
| teamserver\_a\_record | The Teamserver A record. |
| teamserver\_eip | The Teamserver EIP. |

## Notes ##

Running `pre-commit` requires running `terraform init` in every directory that
contains Terraform code. In this repository, these are the main directory and
every directory under `examples/`.

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
