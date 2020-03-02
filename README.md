# cool-assessment-terraform #

[![GitHub Build Status](https://github.com/cisagov/cool-assessment-terraform/workflows/build/badge.svg)](https://github.com/cisagov/cool-assessment-terraform/actions)

This project is used to create an operational assessment environment in
the COOL environment.

## Building the Terraform-based infrastructure ##

Coming soon!

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| aws_region | The AWS region to deploy into (e.g. us-east-1) | string | | yes |
| aws_availability_zone | The AWS availability zone to deploy into (e.g. a, b, c, etc.) | string | | yes |
| tags | Tags to apply to all AWS resources created | map(string) | `{}` | no |

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
