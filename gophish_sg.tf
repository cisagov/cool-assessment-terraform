# Security group for Gophish instances
resource "aws_security_group" "gophish" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Gophish"
    },
  )
}
