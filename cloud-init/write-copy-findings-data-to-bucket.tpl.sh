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
# * vnc_username - the username associated with the VNC user

set -o nounset
set -o errexit
set -o pipefail

path=/home/${vnc_username}/copy-findings-data-to-bucket.sh

# Write the script.  Note that we wrap the delimited in quotes to
# prevent shell variable substitution.
cat > "$path" << "EOF"
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

aws s3 cp "$1" "s3://${findings_data_bucket_name}/$filename_only"
EOF

# Set the ownership and permissions of the script appropriately.
chmod "${permissions}" "$path"
chown "${vnc_username}:${vnc_username}" "$path"
