# skeleton-tf-module #

[![GitHub Build Status](https://github.com/cisagov/skeleton-tf-module/workflows/build/badge.svg)](https://github.com/cisagov/skeleton-tf-module/actions)

This is a generic skeleton project that can be used to quickly get a
new [cisagov](https://github.com/cisagov) [Terraform
module](https://www.terraform.io/docs/modules/index.html) GitHub
repository started.  This skeleton project contains [licensing
information](LICENSE), as well as [pre-commit
hooks](https://pre-commit.com) and
[GitHub Actions](https://github.com/features/actions) configurations
appropriate for the major languages that we use.

See [here](https://www.terraform.io/docs/modules/index.html) for more
details on Terraform modules and the standard module structure.

## Usage ##

```hcl
module "example" {
  source = "github.com/cisagov/skeleton-tf-module"

  aws_region            = "us-west-1"
  aws_availability_zone = "b"
  subnet_id             = "subnet-0123456789abcdef0"
}
```

## Examples ##

- [Basic usage](https://github.com/cisagov/skeleton-tf-module/tree/develop/examples/basic_usage)

<!-- BEGIN_TF_DOCS -->
## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 3.38 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.38 |

## Modules ##

No modules.

## Resources ##

| Name | Type |
|------|------|
| [aws_instance.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_default_tags.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_owner\_account\_id | The ID of the AWS account that owns the Example AMI, or "self" if the AMI is owned by the same account as the provisioner. | `string` | `"self"` | no |
| aws\_availability\_zone | The AWS availability zone to deploy into (e.g. a, b, c, etc.). | `string` | `"a"` | no |
| aws\_region | The AWS region to deploy into (e.g. us-east-1). | `string` | `"us-east-1"` | no |
| subnet\_id | The ID of the AWS subnet to deploy into (e.g. subnet-0123456789abcdef0). | `string` | n/a | yes |

## Outputs ##

| Name | Description |
|------|-------------|
| arn | The EC2 instance ARN. |
| availability\_zone | The AZ where the EC2 instance is deployed. |
| id | The EC2 instance ID. |
| private\_ip | The private IP of the EC2 instance. |
| subnet\_id | The ID of the subnet where the EC2 instance is deployed. |
<!-- END_TF_DOCS -->

## Notes ##

Running `pre-commit` requires running `terraform init` in every directory that
contains Terraform code. In this repository, these are the main directory and
every directory under `examples/`.

## New Repositories from a Skeleton ##

Please see our [Project Setup guide](https://github.com/cisagov/development-guide/tree/develop/project_setup)
for step-by-step instructions on how to start a new repository from
a skeleton. This will save you time and effort when configuring a
new repository!

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
