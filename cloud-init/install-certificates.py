#!/usr/bin/env python3

"""Install certificates from AWS S3.

This file is a template.  It should be processed by terraform.
"""

# Standard Python Libraries
import os

# Third-Party Libraries
import boto3

# Inputs from terraform
CERT_BUCKET_NAME = "${cert_bucket_name}"
CERT_READ_ROLE_ARN = "${cert_read_role_arn}"
REGION = "${region}"
SERVER_FQDN = "${server_fqdn}"

# These files will be copied from the bucket
# and installed in the specified location.
INSTALLATION_MAP = {
    "fullchain.pem": "/var/guacamole/httpd/ssl/self.cert",
    "privkey.pem": "/var/guacamole/httpd/ssl/self-ssl.key",
}

# Create STS client
#
# STS used to be un-regioned, like S3, but now it is regioned.  This
# is the one case where boto3 _does not_ do the right thing when you
# set the region.  We have to set the region-specific endpint URL
# manually.
#
# This is important since the STS VPC endpoint _only_ sets a local DNS
# record to override the _local region's_ public STS endpoint.  If we
# don't do this then boto3 will reach out to the _global_
# https://sts.amazonaws.com URL, and that DNS entry will still point
# to an external IP.
#
# See this link for more information about boto3's perverse behavior
# in the case of STS: https://github.com/boto/boto3/issues/1859.
sts = boto3.client(
    "sts", region_name=REGION, endpoint_url=f"https://sts.{REGION}.amazonaws.com"
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

# The guacamole-composition systemd service is guaranteed to start
# AFTER this cloud-init script runs.  Therefore, we have to ensure
# that the httpd ssl directory exists before we put the certificate
# files in there.  Also, since the guacamole-composition service has
# not started up (when cloud-init executes this script), there's no
# need to restart it to use the newly-deployed certificate.

# Ensure httpd ssl directory exists before we put the cert files there
os.makedirs("/var/guacamole/httpd/ssl/", exist_ok=True)

# Copy each file from the bucket to the local file system
for src, dst in INSTALLATION_MAP.items():
    obj = s3.get_object(
        Bucket=CERT_BUCKET_NAME, Key="live/{}/{}".format(SERVER_FQDN, src)
    )
    with open(dst, "wb") as f:
        f.write(obj["Body"].read())
