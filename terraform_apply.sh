#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# A script for creating assessment environments using
# cisagov/cool-assessment-terraform.
#
# This is necessary because the CloudWatch alarm resources associated
# with the EC2 instances are created using for_each expressions that
# are dynamic-ish.  When an untargeted apply is run, Terraform
# verifies that each for_each attribute is computable without any
# resources being instantiated.  That isn't possible in this case,
# since Terraform must instantiate the EC2 instances before it can
# determine their IDs.  A targeted apply avoids this check, which in
# this case is unnecessary.
#
# Note that instantiating the EC2 instances with a targeted apply and
# then instantiating everything else is equivalent to laying down a
# separate "layer" a la cool-sharedservices-networking.
#
# Examples:
# - See what would be created:
#   $ AWS_PROFILE=cool-user AWS_SHARED_CREDENTIALS_FILE=~/.aws/production_credentials AWS_DEFAULT_REGION=us-east-1 ./terraform_apply.sh -var-file=envX-production.tfvars
# - Create it!  (You will not be prompted.)
#   $ AWS_PROFILE=cool-user AWS_SHARED_CREDENTIALS_FILE=~/.aws/production_credentials AWS_DEFAULT_REGION=us-east-1 ./terraform_apply.sh -auto-approve -var-file=envX-production.tfvars

# Export some environment variables that we want the terraform child
# processes to inherit.
export AWS_PROFILE
export AWS_SHARED_CREDENTIALS_FILE
export AWS_DEFAULT_REGION

# Perform a targeted apply to create the EC2 instances, then create
# everything else.  This is a workaround for the dynamic-ish for_each
# expressions mentioned above.
terraform apply "${@}" \
  -target=aws_iam_role_policy_attachment.provisionassessment_policy_attachment \
  && terraform apply "${@}" \
    -target=aws_default_route_table.operations \
    -target=aws_efs_access_point.access_point \
    -target=aws_efs_file_system.persistent_storage \
    -target=aws_efs_mount_target.target \
    -target=aws_iam_role_policy.gophish_assume_delegated_role_policy \
    -target=aws_iam_role_policy.guacamole_assume_delegated_role_policy \
    -target=aws_iam_role_policy.nessus_assume_delegated_role_policy \
    -target=aws_iam_role_policy.teamserver_assume_delegated_role_policy \
    -target=aws_iam_role_policy.terraformer_assume_delegated_role_policy \
    -target=aws_iam_role_policy_attachment.efs_mount_policy_attachment_assessorportal \
    -target=aws_iam_role_policy_attachment.efs_mount_policy_attachment_debiandesktop \
    -target=aws_iam_role_policy_attachment.efs_mount_policy_attachment_gophish \
    -target=aws_iam_role_policy_attachment.efs_mount_policy_attachment_kali \
    -target=aws_iam_role_policy_attachment.efs_mount_policy_attachment_pentestportal \
    -target=aws_iam_role_policy_attachment.efs_mount_policy_attachment_samba \
    -target=aws_iam_role_policy_attachment.efs_mount_policy_attachment_teamserver \
    -target=aws_iam_role_policy_attachment.efs_mount_policy_attachment_terraformer \
    -target=aws_internet_gateway.assessment \
    -target=aws_nat_gateway.nat_gw \
    -target=aws_network_acl.operations \
    -target=aws_network_acl.private \
    -target=aws_network_acl_rule.operations_egress_to_anywhere_via_any_port \
    -target=aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_1024_thru_3388 \
    -target=aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_3390_thru_50049 \
    -target=aws_network_acl_rule.operations_ingress_from_anywhere_via_ports_50051_thru_65535 \
    -target=aws_network_acl_rule.private_egress_to_anywhere_via_http \
    -target=aws_network_acl_rule.private_egress_to_anywhere_via_https \
    -target=aws_network_acl_rule.private_egress_to_operations_via_ephemeral_ports \
    -target=aws_network_acl_rule.private_ingress_from_anywhere_else_efs \
    -target=aws_network_acl_rule.private_ingress_from_operations_efs \
    -target=aws_network_acl_rule.private_ingress_from_operations_smb \
    -target=aws_network_acl_rule.private_ingress_to_tg_attachment_via_ipa_ports \
    -target=aws_route.cool_operations \
    -target=aws_route.cool_private \
    -target=aws_route.external_operations \
    -target=aws_route.external_private \
    -target=aws_route53_vpc_association_authorization.assessment_private \
    -target=aws_route_table_association.private_route_table_associations \
    -target=aws_security_group_rule.allow_nfs_inbound \
    -target=aws_security_group_rule.allow_nfs_outbound \
    -target=aws_security_group_rule.egress_from_cloudwatch_agent_endpoint_client_to_cloudwatch_agent_endpoint_via_https \
    -target=aws_security_group_rule.egress_from_ec2_endpoint_client_to_ec2_endpoint_via_https \
    -target=aws_security_group_rule.egress_from_ssm_agent_endpoint_client_to_ssm_agent_endpoint_via_https \
    -target=aws_security_group_rule.egress_from_ssm_endpoint_client_to_ssm_endpoint_via_https \
    -target=aws_security_group_rule.egress_from_sts_endpoint_client_to_sts_endpoint_via_https \
    -target=aws_security_group_rule.egress_to_dynamodb_endpoint_via_https \
    -target=aws_security_group_rule.egress_to_s3_endpoint_via_https \
    -target=aws_security_group_rule.ingress_from_cloudwatch_agent_endpoint_client_to_cloudwatch_agent_endpoint_via_https \
    -target=aws_security_group_rule.ingress_from_ec2_endpoint_client_to_ec2_endpoint_via_https \
    -target=aws_security_group_rule.ingress_from_ssm_agent_endpoint_client_to_ssm_agent_endpoint_via_https \
    -target=aws_security_group_rule.ingress_from_ssm_endpoint_client_to_ssm_endpoint_via_https \
    -target=aws_security_group_rule.ingress_from_sts_endpoint_client_to_sts_endpoint_via_https \
    -target=aws_security_group_rule.ingress_from_teamserver_to_gophish_via_smtp \
    -target=aws_security_group_rule.scanner_egress_to_anywhere_via_any_port \
    -target=aws_security_group_rule.smb_client_egress_to_smb_server \
    -target=aws_security_group_rule.smb_server_ingress_from_smb_client \
    -target=aws_vpc_endpoint.dynamodb \
    -target=aws_vpc_endpoint.ec2 \
    -target=aws_vpc_endpoint.ec2messages \
    -target=aws_vpc_endpoint.kms \
    -target=aws_vpc_endpoint.logs \
    -target=aws_vpc_endpoint.monitoring \
    -target=aws_vpc_endpoint.s3 \
    -target=aws_vpc_endpoint.ssm \
    -target=aws_vpc_endpoint.ssmmessages \
    -target=aws_vpc_endpoint.sts \
    -target=aws_vpc_endpoint_route_table_association.s3_operations \
    -target=aws_vpc_endpoint_route_table_association.s3_private \
    -target=aws_vpc_endpoint_subnet_association.ec2 \
    -target=aws_vpc_endpoint_subnet_association.ec2messages \
    -target=aws_vpc_endpoint_subnet_association.kms \
    -target=aws_vpc_endpoint_subnet_association.logs \
    -target=aws_vpc_endpoint_subnet_association.monitoring \
    -target=aws_vpc_endpoint_subnet_association.ssm \
    -target=aws_vpc_endpoint_subnet_association.ssmmessages \
    -target=aws_vpc_endpoint_subnet_association.sts \
    -target=module.email_sending_domain_certreadrole \
    -target=module.guacamole_certreadrole \
    -target=module.read_terraform_state \
    -target=module.run_shell_ssm_document \
    -target=module.vpc_flow_logs \
    -target=null_resource.break_association_with_default_route_table \
  && terraform apply "${@}" \
    -target=aws_instance.assessorportal \
    -target=aws_instance.debiandesktop \
    -target=aws_instance.gophish \
    -target=aws_instance.guacamole \
    -target=aws_instance.kali \
    -target=aws_instance.nessus \
    -target=aws_instance.pentestportal \
    -target=aws_instance.samba \
    -target=aws_instance.teamserver \
    -target=aws_instance.terraformer \
    -target=aws_instance.windows \
    -target=aws_volume_attachment.assessorportal_docker \
    -target=aws_volume_attachment.gophish_docker \
  && terraform apply "${@}"
