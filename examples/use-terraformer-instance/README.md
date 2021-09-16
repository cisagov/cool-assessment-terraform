# Using the Terraform instance #

This example code shows how to use the Terraformer code to spin up a
new instance in the operations subnet of an existing assessment
environment already created by running `terraform apply` with the
[cisagov/cool-assessment-terraform](https://github.com/cisagov/cool-assessment-terraform)
root module.

## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 0.13.0 |
| aws | ~> 3.38 |
| cloudinit | ~> 2.0 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.38 |
| aws.read\_organization\_information | ~> 3.38 |
| cloudinit | ~> 2.0 |
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
| tags | Tags to apply to all AWS resources created. | `map(string)` | `{}` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| teamserver | The Teamserver instance. |
| teamserver\_a\_record | The Teamserver A record. |
| teamserver\_eip | The Teamserver EIP. |
