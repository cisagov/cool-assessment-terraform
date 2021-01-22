# Allow ingress via HTTPS from the desktop gateway security group
resource "aws_security_group_rule" "ingress_from_desktop_gw_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.sts.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.desktop_gateway.id
  from_port                = 443
  to_port                  = 443
}

# Allow ingress via HTTPS from the operations security group
#
# TODO - Only the Nessus instances require this access.  We could
# avoid giving it to the other instance types by creating a separate
# security group for Nessus instances.  See #95 for more details.
resource "aws_security_group_rule" "ingress_from_operations_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.sts.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.operations.id
  from_port                = 443
  to_port                  = 443
}
