#!/usr/bin/env bash
# This is a Terraform template file, and the input variables are
# passed in via templatefile().
#
# shellcheck disable=SC2154

# This script is used write out a bash script that can be used to create an
# assessment artifact archive and copy it to the appropriate S3 buckets.

# Input variables are:
# * artifact_export_bucket_name_1 - the name of the first assessment artifact
#   export S3 bucket
# * artifact_export_bucket_name_2 - the name of the second assessment artifact
#   export S3 bucket
# * artifact_export_path - the path to copy the artifact to in the S3 bucket
# * assessment_id - the identifier for the assessment
# * permissions - the permissions to assign the script, specified in either the
#   octal or symbolic formats understood by chmod
# * vnc_username - the username associated with the VNC user

set -o nounset
set -o errexit
set -o pipefail

path=/home/${vnc_username}/archive-artifact-data-to-bucket.sh

# Write the script.  Note that we wrap the delimiter in quotes to
# prevent shell variable substitution.
cat > "$path" << "EOF"
#!/usr/bin/env bash

# This script creates a gzipped tar archive of the directory containing
# assessment artifacts and then copies that archive to the appropriate S3
# buckets.
#
# Usage: archive-artifact-data-to-bucket.sh /path/to/artifacts_directory

set -o nounset
set -o errexit
set -o pipefail

if [ $# -ne 1 ]; then
  echo "Usage: archive-artifact-data-to-bucket.sh /path/to/artifacts_directory"
  exit 1
fi

full_bucket_path_1="s3://${artifact_export_bucket_name_1}/${artifact_export_path}-${assessment_id}.tgz"
# The owners of the second bucket have requested to add the date in YYYYMMDD format to the object path in that bucket
current_date=$(date +%Y%m%d)
full_bucket_path_2="s3://${artifact_export_bucket_name_2}/${artifact_export_path}-${assessment_id}-$${current_date}.tgz"

# Prompt for confirmation
read -p "Confirm: Archive the contents of $1 and upload to $full_bucket_path_1 and $full_bucket_path_2? [y/N] " -n 1 -r
echo  # Move to a new line

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Exiting without archiving or copying data to S3."
  exit 1
fi

# Change to the parent directory of the artifacts directory
cd "$(dirname "$1")"

# Create the archive
echo "Creating archive..."
# Since we are in the parent directory of the artifacts directory, we don't
# expect to run into any issues related to disk space.  (In our typical use
# case, this directory resides on the EFS volume, which is huge.)
#
# The important thing is to avoid filling up the root disk, so in the event
# that an EFS volume _is not_ being used it probably makes sense to create
# the archive in /tmp.
tar --create --file ${assessment_id}.tgz --gzip --verbose "$(basename "$1")"

# Save the hash of the archive
echo "Calculating archive hash..."
archive_hash=$(sha256sum ${assessment_id}.tgz | cut --delimiter ' ' --fields 1)

# Copy the archive to the first S3 bucket
echo "Copying archive to the first S3 bucket (${artifact_export_bucket_name_1})..."
AWS_SHARED_CREDENTIALS_FILE=/home/${vnc_username}/.aws/artifact_export_credentials AWS_PROFILE=bucket-1 aws s3 cp ${assessment_id}.tgz "$full_bucket_path_1"

# Copy the archive to the second S3 bucket
echo "Copying archive to the second S3 bucket (${artifact_export_bucket_name_2})..."
AWS_SHARED_CREDENTIALS_FILE=/home/${vnc_username}/.aws/artifact_export_credentials AWS_PROFILE=bucket-2 aws s3 cp ${assessment_id}.tgz "$full_bucket_path_2"

# Delete the archive
echo "Deleting archive..."
rm ${assessment_id}.tgz

# Print a summary
echo
echo "Summary:"
echo "  Archive file: ${assessment_id}.tgz"
echo "  Archive hash: $archive_hash"
echo "  S3 bucket 1 path: $full_bucket_path_1"
echo "  S3 bucket 2 path: $full_bucket_path_2"
echo
echo "Success!"
EOF

# Set the ownership and permissions of the script appropriately.
chmod "${permissions}" "$path"
chown "${vnc_username}:${vnc_username}" "$path"
