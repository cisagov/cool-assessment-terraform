#!/usr/bin/env bash

# Input variables are:
# mount_point - the directory to create

set -o nounset
set -o errexit
set -o pipefail

# The "${mount_point}" item below that looks like a shell variable but
# is actually replaced by the Terraform templating engine.  Hence we
# can ignore the "undefined variable" warnings from shellcheck.
#
# shellcheck disable=SC2154
mkdir "${mount_point}"
