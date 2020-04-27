#!/usr/bin/env bash

# nessus-setup.sh - Performs initial nessus setup, including:
#  - Registration with activation code
#  - Creation of admin user (optional)
#  - Update plugins
#  - Rebuild plugin database
#
# NOTES:
#  - The "expect" and "jq" packages are REQUIRED by this script.
#  - Since this script is processed by Terraform's templatefile() function
#    before it is deployed via cloud-init, shell script variables that
#    that would normally be referenced as
#    <dollar-sign><left-curly-brace>var_name<right-curly-brace> are escaped
#    via <dollar-sign><dollar-sign><left-curly-brace>var_name<right-curly-brace>.

set -o nounset
set -o pipefail

nessus_sbin_path="/opt/nessus/sbin"

# Ignore this shellcheck:
# "SC2154: nessus_activation_code is referenced but not assigned."
# since this variable is passed in from any *_cloud_init.tf files
# that call this script.
#
# Similar cases below for ssm_nessus_read_role_arn, aws_region,
# ssm_key_nessus_admin_username, ssm_key_nessus_admin_password, and
# nessus_activation_code are also ignored.
# shellcheck disable=SC2154
activation_code_to_apply="${nessus_activation_code}"

# Assume the role that can read Nessus-related SSM Parameter Store parameters
echo "Assuming role that can read Nessus-related SSM Parameter Store parameters"

# shellcheck disable=SC2154
assumed_role_output=$(aws sts assume-role --role-arn "${ssm_nessus_read_role_arn}" --role-session-name "cloud-init-nessus-setup")

aws_access_key_id=$(echo "$assumed_role_output" | jq -r .Credentials.AccessKeyId)
export AWS_ACCESS_KEY_ID=$aws_access_key_id

aws_secret_access_key=$(echo "$assumed_role_output" | jq -r .Credentials.SecretAccessKey)
export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key

aws_session_token=$(echo "$assumed_role_output" | jq -r .Credentials.SessionToken)
export AWS_SESSION_TOKEN=$aws_session_token

# Fetch the Nessus-related SSM Parameter Store parameters
echo "Reading Nessus-related parameters from SSM Parameter Store..."

# shellcheck disable=SC2154
username_ssm_output=$(aws --region "${aws_region}" ssm get-parameter --name "${ssm_key_nessus_admin_username}" --with-decryption)
username_rc="$?"

if [ "$username_rc" -eq 0 ]
then
  nessus_admin_username=$(echo "$username_ssm_output" | jq -r .Parameter.Value)
  echo "  Nessus admin username successfully read from SSM: $${nessus_admin_username}"
else
  echo "WARNING: Could not read admin username from SSM!"
  nessus_admin_username=""
fi

# shellcheck disable=SC2154
password_ssm_output=$(aws --region "${aws_region}" ssm get-parameter --name "${ssm_key_nessus_admin_password}" --with-decryption)
password_rc="$?"

if [ "$password_rc" -eq 0 ]
then
  nessus_admin_password=$(echo "$password_ssm_output" | jq -r .Parameter.Value)
  echo "  Nessus admin password successfully read from SSM."
else
  echo "WARNING: Could not read admin password from SSM!"
  nessus_admin_password=""
fi


register_nessus()
{
  # Ignore this shellcheck:
  # "SC2034: activation_code appears unused. Verify use (or export if used
  # externally)." since the use of this variable is escaped (due to
  # Terraform templating mentioned above) and shellcheck can't detect that
  # the variable is actually being used.
  # shellcheck disable=SC2034
  activation_code=$1

  echo "Attempting to register Nessus with activation code $${activation_code}..."
  $nessus_sbin_path/nessuscli fetch --register-only "$${activation_code}"
  registration_rc="$?"

  if [ "$registration_rc" -eq 0 ]
  then
    echo "Nessus successfully registered"
    return 0
  else
    echo "ERROR: Nessus registration was unsuccessful"
    return 1
  fi
}

create_admin_user()
{
  username=$1
  # Ignore this shellcheck:
  # "SC2034: password appears unused. Verify use (or export if used
  # externally)." since the use of this variable is escaped (due to
  # Terraform templating mentioned above) and shellcheck can't detect that
  # the variable is actually being used.
  # shellcheck disable=SC2034
  password=$2

  echo "Creating admin user..."
  expect <<- EOF
    set send_slow {1 .1}
    set timeout 300
    spawn $nessus_sbin_path/nessuscli adduser $username
    match_max 100000
    expect "password"
    send -- "$${password}\r"
    expect "password"
    send -- "$${password}\r"
    expect "administrator"
    send -- "y\r"
    expect "BLANK LINE"
    send -- "\r"
    expect "administrator"
    send -- "y\r"
    expect eof
EOF
  user_created="$?"
  if [ "$user_created" -eq 0 ]
  then
    echo "Admin user successfully created"
    return 0
  else
    echo "ERROR: Admin user creation was unsuccessful"
    return 1
  fi
}

update_plugins()
{
  echo "Stopping Nessus service..."
  systemctl stop nessusd

  echo "Updating Nessus plugins..."
  $nessus_sbin_path/nessuscli update --plugins-only

  echo "Rebuilding Nessus plugin database..."
  $nessus_sbin_path/nessusd --recompile

  echo "Starting Nessus service..."
  systemctl start nessusd
}

# Check if Nessus is already registered with an activation code
echo "Checking if Nessus is already registered..."
$nessus_sbin_path/nessuscli fetch --check
registered="$?"

if [ "$registered" -eq 0 ]
then
  echo "Nessus is already registered"
  echo "Checking if activation code matches previously-registered code..."

  # Retrieve the previously-registered activation code
  registered_activation_code="$($nessus_sbin_path/nessuscli fetch --code-in-use | grep -oP '[a-zA-Z0-9]{4}(?:\-[a-zA-Z0-9]{4}){3,4}')"

  if [ "$registered_activation_code" = "$activation_code_to_apply" ]
  then
    echo "Activation code matches previously-registered code"
  else
    echo "Previously-registered activation code ($${registered_activation_code}) differs from code ($${activation_code_to_apply})"
    register_nessus "$activation_code_to_apply"
    register_rc="$?"
    if [ "$register_rc" -eq 0 ]
    then
      update_plugins
    else
      exit $register_rc
    fi
  fi
elif [ "$registered" -eq 1 ]
then
  echo "Nessus is not registered; attempting to register..."
  register_nessus "$activation_code_to_apply"
  register_rc="$?"
  if [ "$register_rc" -eq 0 ]
  then
    update_plugins
  else
    exit $register_rc
  fi
else
  echo "ERROR: Unexpected response from Nessus; exiting"
  exit $registered
fi

if [ "$nessus_admin_username" = "" ]
then
  echo "Admin username is empty; skipping creation of admin user"
else
  echo "Checking if admin user '$${nessus_admin_username}' exists..."
  $nessus_sbin_path/nessuscli lsuser | grep -q "^$${nessus_admin_username}"
  admin_user_exists="$?"
  if [ "$admin_user_exists" -eq 0 ]
  then
    echo "Admin user already exists; no need to create it"
  else
    create_admin_user "$nessus_admin_username" "$nessus_admin_password"
    admin_user_created="$?"
    if [ "$admin_user_exists" -ne 0 ]
    then
      exit $admin_user_created
    fi
  fi
fi
