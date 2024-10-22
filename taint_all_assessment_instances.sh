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

# I'm using short options here because MacOS's version of sed doesn't
# support long options.  I'm also using the -E flag because MacOS's
# version of sed does not use extended regexes by default.
INSTANCES=$(terraform state list \
  | sed -Ee '/^aws_instance\.(guacamole|samba\[[[:digit:]]+\])$/d' \
    -Ee '/^aws_instance\..*$/p' -n)

for instance in $INSTANCES; do
  terraform taint "$instance"
done
