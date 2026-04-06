#!/usr/bin/env bash
# This is a Terraform template file, and the input variables are
# passed in via templatefile().
#
# shellcheck disable=SC2154

# This script is used to write out an AWS configuration to the home
# directory of a specified user.  The AWS configuration gives the user
# access to assessment images bucket read-only role.

# Input variables are:
# * aws_region - the AWS region where the roles are to be assumed
# * permissions - the octal permissions to assign the AWS configuration
# * read_images_bucket_role_arn - the ARN of the IAM role that can be assumed
#   to read images from the assessment images bucket
# * vnc_username - the username associated with the VNC user

set -o nounset
set -o errexit
set -o pipefail

path=/home/${vnc_username}/.aws/credentials

# Create the path where the AWS config file will be created, and set
# its ownership appropriately.
#
# I'd like to use some bash shell parameter expansion here (see
# https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html,
# for example) to extract the directory from the path, but Terraform's
# templating engine balks at that; hence, I am using dirname instead.
d=$(dirname "$path")
mkdir --parents "$d"
chown --recursive "${vnc_username}:${vnc_username}" "$d"

# Write the AWS config file
cat > "$path" << EOF
[default]
credential_source = Ec2InstanceMetadata
region = ${aws_region}
role_arn = ${read_images_bucket_role_arn}
sts_regional_endpoints = regional
EOF

# Set the ownership and permissions of the AWS config file
# appropriately.
chmod "${permissions}" "$path"
chown "${vnc_username}:${vnc_username}" "$path"
