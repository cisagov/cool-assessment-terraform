#!/usr/bin/env python3

"""Create Guacamole connection setup SQL.

This script fetches data from AWS SSM and then uses pystache to render a
SQL template using that SSM data.
"""

# Standard Python Libraries
import os

# Third-Party Libraries
import boto3
import pystache

SQL_TEMPLATE = "${sql_template_fullpath}"
# NOTE: Postgres processes initialization files alphabetically, so it's
# important to name this file so it runs after the file that defines the
# Guacamole tables and users ("00_initdb.sql").
SQL_OUTPUT_FILE = "${guac_connection_setup_path}/${guac_connection_setup_filename}"

# Inputs from terraform
SSM_READ_ROLE_ARN = "${ssm_vnc_read_role_arn}"
# nosec on following line tells bandit (pre-commit hook) to ignore security
# warnings; otherwise bandit complains about "Possible hardcoded password"
SSM_KEY_VNC_PASSWORD = "${ssm_key_vnc_password}"  # nosec
SSM_KEY_VNC_USER = "${ssm_key_vnc_user}"
SSM_KEY_VNC_USER_PRIVATE_SSH_KEY = "${ssm_key_vnc_user_private_ssh_key}"

# Create STS client
sts = boto3.client("sts")

# Assume the role that can read the SSM parameters
stsresponse = sts.assume_role(
    RoleArn=SSM_READ_ROLE_ARN, RoleSessionName="guacamole_connection_setup"
)
newsession_id = stsresponse["Credentials"]["AccessKeyId"]
newsession_key = stsresponse["Credentials"]["SecretAccessKey"]
newsession_token = stsresponse["Credentials"]["SessionToken"]

# Create a new client to access SSM using the temporary credentials
ssm = boto3.client(
    "ssm",
    region_name="${aws_region}",
    aws_access_key_id=newsession_id,
    aws_secret_access_key=newsession_key,
    aws_session_token=newsession_token,
)

# Fetch the required parameters from SSM
ssm_data = dict()
for ssm_key, param_name in (
    (SSM_KEY_VNC_USER, "vnc_username"),
    (SSM_KEY_VNC_PASSWORD, "vnc_password"),
    (SSM_KEY_VNC_USER_PRIVATE_SSH_KEY, "vnc_user_private_ssh_key"),
):
    ssm_parameter = ssm.get_parameter(Name=ssm_key, WithDecryption=True)["Parameter"]
    ssm_data[param_name] = ssm_parameter["Value"]

# Ensure output (postgres initialization) directory is present before we put
# our sql file there
os.makedirs("${guac_connection_setup_path}", exist_ok=True)

# Render template with SSM data and write output file
with open(SQL_TEMPLATE) as infile:
    with open(SQL_OUTPUT_FILE, "w") as outfile:
        outfile.write(pystache.render(infile.read(), ssm_data))
