#!/usr/bin/env bash

# This script copies Docker data from the default data-root directory to
# a new directory.

# Input variables:
# mount_point (optional) - The mount point of the volume containing the new
# data-root directory
# new_data_root_dir - The new (non-default) data-root directory to store
# Docker data

# This is a Terraform template file, and the input variables are
# passed in via the templatefile().
#
# shellcheck disable=SC2154
set -o nounset
set -o errexit

# Check if we have previously populated the new data-root directory
if [[ ! -d "${new_data_root_dir}/volumes" ]]
then
  if [[ -n "${mount_point}" ]]
  then
    # Ensure volume containing new_data_root_dir has been mounted
    until findmnt "${mount_point}"
    do
      sleep 2
      echo Waiting for "${mount_point}" to be mounted...
    done
  fi

  # Copy Docker data to new location
  cp --preserve --recursive "/var/lib/docker/"* "${new_data_root_dir}"
fi

# Check if default directory still exists
if [[ -d /var/lib/docker ]]
then
  # Rename default directory for safe keeping
  mv /var/lib/docker /var/lib/docker.orig
fi
