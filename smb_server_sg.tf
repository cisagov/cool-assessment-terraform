# Security group for Samba file share servers
resource "aws_security_group" "smb_server" {
  provider = aws.provisionassessment

  tags = {
    Name = "SMB server"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow ingress from SMB client instances via port 445 (SMB)
resource "aws_security_group_rule" "smb_server_ingress_from_smb_client" {
  provider = aws.provisionassessment

  from_port                = 445
  protocol                 = "tcp"
  security_group_id        = aws_security_group.smb_server.id
  source_security_group_id = aws_security_group.smb_client.id
  to_port                  = 445
  type                     = "ingress"
}
