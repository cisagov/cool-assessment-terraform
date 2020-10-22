# Launch an example EC2 instance in a new VPC #

## Usage ##

To run this example you need to execute the `terraform init` command
followed by the `terraform apply` command.

Note that this example may create resources which cost money. Run
`terraform destroy` when you no longer need these resources.

## Requirements ##

No requirements.

## Providers ##

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami_owner_account_id | The ID of the AWS account that owns the AMI, or "self" if the AMI is owned by the same account as the provisioner. | `string` | `self` | no |
| aws_availability_zone | The AWS availability zone to deploy into (e.g. a, b, c, etc.) | `string` | `a` | no |
| aws_region | The AWS region to deploy into (e.g. us-east-1). | `string` | `us-east-1` | no |
| tf_role_arn | The ARN of the role that can terraform non-specialized resources. | `string` | n/a | yes |

## Outputs ##

| Name | Description |
|------|-------------|
| arn | The EC2 instance ARN |
| availability_zone | The AZ where the EC2 instance is deployed |
| id | The EC2 instance ID |
| private_ip | The private IP of the EC2 instance |
| subnet_id | The ID of the subnet where the EC2 instance is deployed |
