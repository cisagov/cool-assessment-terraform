#!/usr/bin/env bash

# This script is used to inject the Wazuh agent name into the agent's
# configuration.

# Input variables are:
# account_name - the name of the AWS account in which the instance
# resides (e.g., env0)
# deployment_name - the name of the COOL deployment where the instance
# resides (e.g., dev-a)
# hostname - the hostname for the instance (e.g., kali0)

# This is a Terraform template file, and the input variables are
# passed in via templatefile().
#
# shellcheck disable=SC2154
set -o nounset
set -o errexit
set -o pipefail

CONFIG_FILE=/var/ossec/etc/ossec.conf
TEMP_FILE=$(mktemp)

# The ossec.conf file is ill-formed XML with no root element, so we
# inject a root element and create a temporary file before processing
# with xmlstarlet.
{
  echo "<root>"
  cat "$CONFIG_FILE"
  echo "</root>"
} > "$TEMP_FILE"

# Check if the enrollment node exists and add it if it does not.
COUNT=$(xmlstarlet select \
  --template \
  --value-of 'count(/root/ossec_config/client/enrollment)' \
  "$TEMP_FILE")
if [ "$COUNT" -le 0 ]; then
  # Add the enrollment node
  xmlstarlet edit --omit-decl --inplace \
    --subnode "/root/ossec_config/client" \
    --type elem -n enrollment \
    "$TEMP_FILE"
fi

# Check if the agent_name node exists and create it if it does not.
# If it already exists, ensure that it has the correct value.
COUNT=$(xmlstarlet select \
  --template \
  --value-of 'count(/root/ossec_config/client/enrollment/agent_name)' \
  "$TEMP_FILE")
if [ "$COUNT" -gt 0 ]; then
  # agent_name exists, so simply ensure it has the correct value
  xmlstarlet edit --omit-decl --inplace \
    --update "/root/ossec_config/client/enrollment/agent_name" \
    --value "${deployment_name}.${account_name}.${hostname}" \
    "$TEMP_FILE"
else
  # agent_name does not exist, so create it
  xmlstarlet edit --omit-decl --inplace \
    --subnode "/root/ossec_config/client/enrollment" \
    --type elem -n agent_name \
    --value "${deployment_name}.${account_name}.${hostname}" \
    "$TEMP_FILE"
fi

# Now remove the fake root tag by deleting the first and last lines of
# the file.
sed '1d; $d' "$TEMP_FILE" > "$CONFIG_FILE"

# Clean up
rm "$TEMP_FILE"

# Now that we have a correct configuration we can start and enable the
# Wazuh agent service.
systemctl enable --now wazuh-agent.service
