# Security group for Wazuh clients
resource "aws_security_group" "wazuh_client" {
  provider = aws.provisionassessment

  tags = {
    Name = "Wazuh client"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow TCP egress via port 1514 (client-manager communication) and
# port 1515 (client-manager registration).
resource "aws_security_group_rule" "wazuh_client_egress" {
  provider = aws.provisionassessment

  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 1514
  protocol          = "tcp"
  security_group_id = aws_security_group.wazuh_client.id
  to_port           = 1515
  type              = "egress"
}
