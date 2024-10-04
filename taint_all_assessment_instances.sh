#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# A script for tainting all assessment instance types in
# cisagov/cool-assessment-terraform.  Note that this does not include
# the Guacamole or Samba instances.
#
# Example:
# $ AWS_PROFILE=cool-user AWS_SHARED_CREDENTIALS_FILE=~/.aws/production_credentials AWS_DEFAULT_REGION=us-east-1 ./taint_all_assessment_instances.sh

# Export some environment variables that we want the terraform child
# processes to inherit.
export AWS_PROFILE
export AWS_SHARED_CREDENTIALS_FILE
export AWS_DEFAULT_REGION

INSTANCES=$(terraform state list \
  | sed --expression '/^aws_instance\.\(guacamole\|samba\)$/d' \
    --expression '/^aws_instance\..*$/p' \
    --quiet)

for instance in $INSTANCES; do
  terraform taint "$instance"
done
