#!/usr/bin/env bash
# This is a Terraform template file, and the input variables are
# passed in via templatefile().
#
# shellcheck disable=SC2154

# This script is used to write out an AWS configuration to the home
# directory of a specified user.  The AWS configuration gives the user
# credentials that allow writing to the assessment artifact export S3 bucket.

# Input variables are:
# * aws_access_key_id - the AWS access key ID
# * aws_region - the AWS region of the S3 bucket
# * aws_secret_access_key - the AWS secret access key
# * permissions - the octal permissions to assign the AWS
#   configuration
# * vnc_username - the username associated with the VNC user

set -o nounset
set -o errexit
set -o pipefail

path=/home/${vnc_username}/.aws/artifact_export_credentials

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
aws_access_key_id = ${aws_access_key_id}
aws_secret_access_key = ${aws_secret_access_key}
region = ${aws_region}
EOF

# Set the ownership and permissions of the AWS config file
# appropriately.
chmod "${permissions}" "$path"
chown "${vnc_username}:${vnc_username}" "$path"
