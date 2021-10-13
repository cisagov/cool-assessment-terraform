# Security group for Samba file share clients
resource "aws_security_group" "smb_client" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "SMB client"
  }
}

# Allow egress to SMB server instances via port 445 (SMB)
resource "aws_security_group_rule" "smb_client_egress_to_smb_server" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.smb_client.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.smb_server.id
  from_port                = 445
  to_port                  = 445
}
