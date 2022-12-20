#!/usr/bin/env bash
# This is a Terraform template file, and the input variables are
# passed in via templatefile().
#
# shellcheck disable=SC2154

# This script is used write out a bash script used to copy findings
# data to the appropriate S3 bucket.

# Input variables are:
# * aws_region - the AWS region where the roles are to be assumed
# * findings_data_bucket_name - the name of the findings data S3
#   bucket
# * permissions - the octal permissions to assign the script
# * vnc_read_parameter_store_role_arn - the ARN of the role that
#   grants read-only access to certain VNC-related SSM Parameter Store
#   parameters, including the VNC username
# * vnc_username_parameter_name - the name of the SSM Parameter Store
#   parameter containing the VNC user's username

set -o nounset
set -o errexit
set -o pipefail

# Temporarily assume a role in order to retrieve the VNC user's
# username from SSM Parameter Store.
aws_sts_output=$(aws sts assume-role \
  --role-arn="${vnc_read_parameter_store_role_arn}" \
  --role-session-name=cloud-init)
access_key_id=$(sed --quiet \
  's/^[[:blank:]]*"AccessKeyId": "\([[:graph:]]\+\)",$/\1/p' \
  <<< "$aws_sts_output")
secret_access_key=$(sed --quiet \
  's/^[[:blank:]]*"SecretAccessKey": "\([[:graph:]]\+\)",$/\1/p' \
  <<< "$aws_sts_output")
session_token=$(sed --quiet \
  's/^[[:blank:]]*"SessionToken": "\([[:graph:]]\+\)",$/\1/p' \
  <<< "$aws_sts_output")

# Now retrieve the VNC user's username from SSM Parameter Store
ssm_response=$(AWS_ACCESS_KEY_ID=$access_key_id \
  AWS_SECRET_ACCESS_KEY=$secret_access_key \
  AWS_SESSION_TOKEN=$session_token \
  aws --region "${aws_region}" \
  ssm get-parameter \
  --name /vnc/username --with-decryption)
vnc_username=$(sed --quiet \
  's/^[[:blank:]]*"Value": "\([[:graph:]]\+\)",$/\1/p' \
  <<< "$ssm_response")

path=/home/$vnc_username/copy-findings-data-to-bucket.sh

# Write the script
cat > "$path" << EOF
#!/usr/bin/env bash

# This script copies a file containing findings data to the
# appropriate S3 bucket.
#
# Usage:  copy-findings-data-to-bucket.sh /path/to/RV0123-data.json

# Input variables:
# findings_data_bucket_name - The name of the S3 bucket where findings
# data is to be written

# This is a Terraform template file, and the input variables are
# passed in via templatefile().
#
# shellcheck disable=SC2154
set -o nounset
set -o errexit
set -o pipefail

filename_only=$(basename "$1")

aws s3 cp "$1" "arn:aws:s3:::${findings_data_bucket_name}/$filename_only"
EOF

# Set the ownership and permissions of the script appropriately.
chmod "${permissions}" "$path"
chown "$vnc_username:$vnc_username" "$path"
