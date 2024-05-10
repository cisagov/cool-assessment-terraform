# Security group for Samba file share clients
resource "aws_security_group" "smb_client" {
  provider = aws.provisionassessment

  tags = {
    Name = "SMB client"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow egress to SMB server instances via port 445 (SMB)
resource "aws_security_group_rule" "smb_client_egress_to_smb_server" {
  provider = aws.provisionassessment

  from_port                = 445
  protocol                 = "tcp"
  security_group_id        = aws_security_group.smb_client.id
  source_security_group_id = aws_security_group.smb_server.id
  to_port                  = 445
  type                     = "egress"
}
