#!/usr/bin/env bash
# This is a Terraform template file, and the input variables are
# passed in via templatefile().
#
# shellcheck disable=SC2154

# This script is used write out a bash script that can be used to create an
# assessment artifact archive and copy it to the appropriate S3 bucket.

# Input variables are:
# * artifact_export_bucket_name - the name of the assessment artifact export S3
#   bucket
# * artifact_export_path - the path to copy the artifact to in the S3 bucket
# * assessment_id - the identifier for the assessment
# * permissions - the octal permissions to assign the script
# * vnc_username - the username associated with the VNC user

set -o nounset
set -o errexit
set -o pipefail

path=/home/${vnc_username}/archive-artifact-data-to-bucket.sh

# Write the script.  Note that we wrap the delimited in quotes to
# prevent shell variable substitution.
cat > "$path" << "EOF"
#!/usr/bin/env bash

# This script creates a gzipped tar archive of the directory containing
# assessment artifacts and then copies that archive to the appropriate S3
# bucket.
#
# Usage:  copy-artifact-data-to-bucket.sh /path/to/artifacts_directory

set -o nounset
set -o errexit
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage:  copy-artifact-data-to-bucket.sh /path/to/artifacts_directory"
  exit 1
fi

full_bucket_path="s3://${artifact_export_bucket_name}/${artifact_export_path}-${assessment_id}.tgz"

# Prompt for confirmation
read -p "Confirm: Archive the contents of $1 and upload to $full_bucket_path? [y/N] " -n 1 -r
echo  # Move to a new line

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Exiting without archiving or copying data to S3."
  exit 1
fi

# Change to the parent directory of the artifacts directory
cd "$(dirname "$1")"

# Create the archive
echo "Creating archive..."
tar --create --file ${assessment_id}.tgz --gzip --verbose "$(basename "$1")"

# Copy the archive to the S3 bucket
echo "Copying archive to S3..."
AWS_SHARED_CREDENTIALS_FILE=/home/${vnc_username}/.aws/artifact_export_credentials aws s3 cp ${assessment_id}.tgz "$full_bucket_path"

# Delete the archive
echo "Deleting archive..."
rm ${assessment_id}.tgz
echo "Done."
EOF

# Set the ownership and permissions of the script appropriately.
chmod "${permissions}" "$path"
chown "${vnc_username}:${vnc_username}" "$path"
