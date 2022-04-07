#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# A script for destroying assessment environments created using
# cisagov/cool-assessment-terraform.
#
# This is necessary because the CloudWatch alarm resources associated
# with the EC2 instances are created using for_each expressions that
# are dynamic-ish.  When an untargeted destroy is run, Terraform
# verifies that each for_each attribute is computable without any
# resources needing to be instantiated.  That isn't possible in this
# case, since Terraform must instantiate the EC2 instances before it
# can get determine their IDs.  A targeted destroy avoids this check,
# which in this case is unnecessary.
#
# Examples:
# - See what would be destroyed:
#   $ AWS_PROFILE=cool-user AWS_SHARED_CREDENTIALS_FILE=~/.aws/production_credentials AWS_DEFAULT_REGION=us-east-1 ./terraform_destroy_all.sh -var-file=envX-production.tfvars
# - Destroy it!  (You will not be prompted.)
#   $ AWS_PROFILE=cool-user AWS_SHARED_CREDENTIALS_FILE=~/.aws/production_credentials AWS_DEFAULT_REGION=us-east-1 ./terraform_destroy_all.sh -auto-apply -var-file=envX-production.tfvars

# Export some environment variables that we want the terraform child
# processes to inherit.
export AWS_PROFILE
export AWS_SHARED_CREDENTIALS_FILE
export AWS_DEFAULT_REGION

# Create a list of resources to target from the terraform state and
# then pass them to terraform destroy.
terraform state list | sed "s/^/-target='/;s/$/'/" | xargs terraform destroy "$@"
