# Security group for Samba file share servers
resource "aws_security_group" "smb_server" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "SMB server"
  }
}

# Allow ingress from SMB client instances via port 445 (SMB)
resource "aws_security_group_rule" "smb_server_ingress_from_smb_client" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.smb_server.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.smb_client.id
  from_port                = 445
  to_port                  = 445
}
