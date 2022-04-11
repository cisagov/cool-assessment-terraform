#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# A script for creating assessment environments using
# cisagov/cool-assessment-terraform.
#
# This is necessary because the CloudWatch alarm resources associated
# with the EC2 instances are created using for_each expressions that
# are dynamic-ish.  When an untargeted apply is run, Terraform
# verifies that each for_each attribute is computable without any
# resources being instantiated.  That isn't possible in this case,
# since Terraform must instantiate the EC2 instances before it can
# determine their IDs.  A targeted apply avoids this check, which in
# this case is unnecessary.
#
# Note that instantiating the EC2 instances with a targeted apply and
# then instantiating everything else is equivalent to laying down a
# separate "layer" a la cool-sharedservices-networking.
#
# Examples:
# - See what would be created:
#   $ AWS_PROFILE=cool-user AWS_SHARED_CREDENTIALS_FILE=~/.aws/production_credentials AWS_DEFAULT_REGION=us-east-1 ./terraform_apply.sh -var-file=envX-production.tfvars
# - Create it!  (You will not be prompted.)
#   $ AWS_PROFILE=cool-user AWS_SHARED_CREDENTIALS_FILE=~/.aws/production_credentials AWS_DEFAULT_REGION=us-east-1 ./terraform_apply.sh -auto-approve -var-file=envX-production.tfvars

# Export some environment variables that we want the terraform child
# processes to inherit.
export AWS_PROFILE
export AWS_SHARED_CREDENTIALS_FILE
export AWS_DEFAULT_REGION

# Perform a targeted apply to create the EC2 instances, then create
# everything else.  This is a workaround for the dynamic-ish for_each
# expressions mentioned above.
terraform apply "${@}" \
  -target=aws_iam_role_policy_attachment.provisionassessment_policy_attachment \
  && terraform apply "${@}" \
    -target=aws_instance.assessorportal \
    -target=aws_instance.debiandesktop \
    -target=aws_instance.gophish \
    -target=aws_instance.guacamole \
    -target=aws_instance.kali \
    -target=aws_instance.nessus \
    -target=aws_instance.pentestportal \
    -target=aws_instance.samba \
    -target=aws_instance.teamserver \
    -target=aws_instance.terraformer \
    -target=aws_instance.windows \
  && terraform apply "${@}"
