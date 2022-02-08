#!/usr/bin/env python3

"""Install certificates from AWS S3.

This file is a template.  It should be processed by terraform.
"""

# Standard Python Libraries
from pathlib import Path
import sys

# Third-Party Libraries
import boto3
import botocore

# Inputs from terraform
AWS_REGION = "${aws_region}"
CERT_BUCKET_NAME = "${cert_bucket_name}"
CERT_READ_ROLE_ARN = "${cert_read_role_arn}"
CREATE_DEST_DIRS = "${create_dest_dirs}" == "true"
FULL_CHAIN_PEM_DEST = "${full_chain_pem_dest}"
PRIV_KEY_PEM_DEST = "${priv_key_pem_dest}"
SERVER_FQDN = "${server_fqdn}"

# These files will be copied from the bucket
# and installed in the specified location.
INSTALLATION_MAP = {
    "fullchain.pem": FULL_CHAIN_PEM_DEST,
    "privkey.pem": PRIV_KEY_PEM_DEST,
}

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

# Assume the role that can read the certificate
stsresponse = sts.assume_role(
    RoleArn=CERT_READ_ROLE_ARN, RoleSessionName="cert_installation"
)
newsession_id = stsresponse["Credentials"]["AccessKeyId"]
newsession_key = stsresponse["Credentials"]["SecretAccessKey"]
newsession_token = stsresponse["Credentials"]["SessionToken"]

# Create a new client to access S3 using the temporary credentials
s3 = boto3.client(
    "s3",
    aws_access_key_id=newsession_id,
    aws_secret_access_key=newsession_key,
    aws_session_token=newsession_token,
)

# The following two lines were added to support Guacamole instances.  In
# that case the guacamole-composition systemd service is guaranteed to
# start AFTER this cloud-init script runs.  Therefore, we have to
# ensure that the httpd ssl directory exists before we put the
# certificate files in there.  Also, since the guacamole-composition
# service has not started up (when cloud-init executes this script),
# there's no need to restart it to use the newly-deployed certificate.
#
# Ensure destination directories exist before we put the cert files
# there.
if CREATE_DEST_DIRS:
    Path.mkdir(Path(FULL_CHAIN_PEM_DEST).parent, parents=True, exist_ok=True)
    Path.mkdir(Path(PRIV_KEY_PEM_DEST).parent, parents=True, exist_ok=True)

# Copy each file from the bucket to the local file system
for src, dst in INSTALLATION_MAP.items():
    try:
        obj = s3.get_object(
            Bucket=CERT_BUCKET_NAME, Key="live/{}/{}".format(SERVER_FQDN, src)
        )
    except botocore.exceptions.ClientError as e:
        print(
            "Error fetching '{}/live/{}/{}' from S3: {}".format(
                CERT_BUCKET_NAME, SERVER_FQDN, src, e
            )
        )
        print("Exiting script!")
        sys.exit(-1)
    with open(dst, "wb") as f:
        f.write(obj["Body"].read())
