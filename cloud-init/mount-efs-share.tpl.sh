#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# This is a Terraform template file, and the mount_point variable is
# passed in via the templatefile().
#
# shellcheck disable=SC2154
until findmnt "${mount_point}"; do
  sleep 2
  echo Attempting to mount EFS share at "${mount_point}".
  mount --all
done
