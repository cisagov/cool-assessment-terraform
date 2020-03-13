# Set up private DNS zone for this assessment
resource "aws_route53_zone" "assessment_private" {
  provider = aws.provisionassessment

  name = "${var.private_domain}."

  vpc {
    vpc_id = aws_vpc.assessment.id
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s Private Zone", var.private_domain)
    },
  )
  comment = "Terraform Workspace: ${terraform.workspace}"
}