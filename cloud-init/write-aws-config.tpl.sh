#!/usr/bin/env bash
# This is a Terraform template file, and the input variables are
# passed in via templatefile().
#
# shellcheck disable=SC2154

# This script is used write out an AWS configuration to the home
# directory of a specified user.  The AWS configuration gives the user
# access to the Terraformer, organization read-only, and
# cisagov/cool-assessment-terraform Terraform state read-only roles.

# Input variables are:
# * aws_region - the AWS region where the roles are to be assumed
# * owner - the user in whose home directory the AWS configuration
#   file is being created
# * path - the full path to the AWS configuration file
# * permissions - the octal permissions to assign the AWS
#   configuration
# * read_cool_assessment_terraform_state_role_arn - the ARN of the
#   IAM role that can be assumed to read the Terraform state of the
#   cisagov/cool-assessment-terraform root module
# * organization_read_role_arn - the ARN of the IAM role that can be
#   assumed to read information about the AWS Organization to which
#   the assessment environment belongs
# * terraformer_role_arn - the ARN of the Terraformer role, which can
#   be assumed to create certain resources in the assessment
#   environment

set -o nounset
set -o errexit
set -o pipefail

# Create the path where the AWS config file will be created, and set
# its ownership appropriately.
#
# I'd like to use some bash shell parameter expansion here (see
# https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html,
# for example) to extract the directory from the path, but Terraform's
# templating engine balks at that; hence, I am using dirname instead.
d=$(dirname "${path}")
mkdir -p "$d"
chown -R "${owner}" "$d"

# Write the AWS config file
cat > "${path}" << EOF
[default]
credential_source = Ec2InstanceMetadata
region = ${aws_region}
role_arn = ${terraformer_role_arn}
sts_regional_endpoints = regional

[read_cool_assessment_terraform_state]
credential_source = Ec2InstanceMetadata
region = ${aws_region}
role_arn = ${read_cool_assessment_terraform_state_role_arn}
sts_regional_endpoints = regional

[read_organization_information]
credential_source = Ec2InstanceMetadata
region = ${aws_region}
role_arn = ${organization_read_role_arn}
sts_regional_endpoints = regional
EOF

# Set the ownership and permissions of the AWS config file
# appropriately.
chmod "${permissions}" "${path}"
chown "${owner}" "${path}"
