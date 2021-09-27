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

INSTANCE_HOSTNAMES = "${instance_hostnames}".split(",")
SQL_TEMPLATE = "${sql_template_fullpath}"
# NOTE: Postgres processes initialization files alphabetically, so it's
# important to name this file so it runs after the file that defines the
# Guacamole tables and users ("00_initdb.sql").
SQL_OUTPUT_FILE_PREFIX = (
    "${guac_connection_setup_path}/${guac_connection_setup_filename}"
)

# Inputs from terraform
AWS_REGION = "${aws_region}"
SSM_READ_ROLE_ARN = "${ssm_vnc_read_role_arn}"
# nosec on following line tells bandit (pre-commit hook) to ignore security
# warnings; otherwise bandit complains about "Possible hardcoded password"
SSM_KEY_RDP_PASSWORD = "${ssm_key_rdp_password}"  # nosec
SSM_KEY_RDP_USER = "${ssm_key_rdp_user}"
# nosec on following line tells bandit (pre-commit hook) to ignore security
# warnings; otherwise bandit complains about "Possible hardcoded password"
SSM_KEY_VNC_PASSWORD = "${ssm_key_vnc_password}"  # nosec
SSM_KEY_VNC_USER = "${ssm_key_vnc_user}"
SSM_KEY_VNC_USER_PRIVATE_SSH_KEY = "${ssm_key_vnc_user_private_ssh_key}"

# Create STS client
#
# STS used to be un-regioned, like S3, but now it is regioned.  This
# is the one case where boto3 _does not_ do the right thing when you
# set the region.  We have to set the region-specific endpoint URL
# manually.
#
# This is important since the STS VPC endpoint _only_ sets a local DNS
# record to override the _local region's_ public STS endpoint.  If we
# don't set the endpoint URL then boto3 will reach out to the _global_
# https://sts.amazonaws.com URL, and that DNS entry will still point
# to an external IP.
#
# See this link for more information about boto3's perverse behavior
# in the case of STS: https://github.com/boto/boto3/issues/1859.
sts = boto3.client(
    "sts",
    region_name=AWS_REGION,
    endpoint_url=f"https://sts.{AWS_REGION}.amazonaws.com",
)

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
    region_name=AWS_REGION,
    aws_access_key_id=newsession_id,
    aws_secret_access_key=newsession_key,
    aws_session_token=newsession_token,
)

data_for_pystache = dict()
# Fetch the required parameters from SSM
for ssm_key, param_name in (
    (SSM_KEY_RDP_USER, "rdp_username"),
    (SSM_KEY_RDP_PASSWORD, "rdp_password"),
    (SSM_KEY_VNC_USER, "vnc_username"),
    (SSM_KEY_VNC_PASSWORD, "vnc_password"),
    (SSM_KEY_VNC_USER_PRIVATE_SSH_KEY, "vnc_user_private_ssh_key"),
):
    ssm_parameter = ssm.get_parameter(Name=ssm_key, WithDecryption=True)["Parameter"]
    data_for_pystache[param_name] = ssm_parameter["Value"]

# Ensure output (postgres initialization) directory is present before we put
# our sql file there
os.makedirs("${guac_connection_setup_path}", exist_ok=True)

# Render template with SSM and hostname data,
# then write output file for each host
for host in INSTANCE_HOSTNAMES:
    data_for_pystache["instance_hostname"] = host
    if host.startswith("windows"):
        data_for_pystache.update(
            {
                "vnc_connection": False,
                "connection_port": 3389,
                "connection_protocol": "rdp",
            }
        )
    else:
        data_for_pystache.update(
            {
                "vnc_connection": True,
                "connection_port": 5901,
                "connection_protocol": "vnc",
            }
        )
    sql_output_file = f"{SQL_OUTPUT_FILE_PREFIX}_{host}.sql"
    with open(SQL_TEMPLATE) as infile:
        with open(sql_output_file, "w") as outfile:
            outfile.write(pystache.render(infile.read(), data_for_pystache))
