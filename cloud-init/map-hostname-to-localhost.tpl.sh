#!/usr/bin/env bash

# This script checks a hosts file to see if it includes a mapping between
# a given hostname and the local host (127.0.0.1).  If that mapping does not
# exist, it is created.

# Input variables:
# hostname - The hostname to map to 127.0.0.1.
# hosts_file - The full path to the hosts file to be updated (if necessary).

# This is a Terraform template file, and the hostname and hosts_file variables
# are passed in via templatefile().
#
# Since this script is processed by Terraform's templatefile() function
# before it is deployed via cloud-init, shell script variables that
# that would normally be referenced as
# <dollar-sign><left-curly-brace>var_name<right-curly-brace> are escaped
# via <dollar-sign><dollar-sign><left-curly-brace>var_name<right-curly-brace>.
set -o nounset
set -o errexit
set -o pipefail

# Put Terraform-supplied hostname in a shell variable so we can use parameter
# expansion to create the escaped hostname.
hostname="${hostname}"

# Escape periods in hostname
# e.g. example.com -> example\.com
#
# SC2034 ("escaped_hostname appears unused"): escaped_hostname is used in
# the grep command below.
# shellcheck disable=SC2034
escaped_hostname="$${hostname//\./\\.}"

# Check whether hostname is already mapped to 127.0.0.1 in the hosts file
# We temporarily disable errexit so that our script won't terminate in the
# case where our grep command fails to find anything.
set +o errexit

# beautysh (pre-commit hook) doesn't handle the following grep correctly, so
# we have to temporarily turn off the formatting.
# @formatter:off
# The hosts_file variable is passed in via Terraform templatefile().
# shellcheck disable=SC2154
grep --quiet --ignore-case "^127\.0\.0\.1\s$${escaped_hostname}\s*$" "${hosts_file}"
# @formatter:on
grep_rc="$?"
set -o errexit

if [[ "$grep_rc" -ne 0 ]]
then
  # Add the mapping to the hosts file
  echo -e "\n127.0.0.1 ${hostname}" >> "${hosts_file}"
else
  echo "No changes: ${hostname} already mapped to 127.0.0.1 in ${hosts_file}"
fi
