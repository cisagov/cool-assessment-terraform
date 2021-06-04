# Set up private DNS zone for this assessment
resource "aws_route53_zone" "assessment_private" {
  provider = aws.provisionassessment

  name = "${local.private_domain}."

  vpc {
    vpc_id = aws_vpc.assessment.id
  }

  tags = {
    Name = format("%s Private Zone", local.private_domain)
  }
  comment = "Terraform Workspace: ${terraform.workspace}"
}


# Private Route53 reverse zones for the private subnets
resource "aws_route53_zone" "private_subnet_reverse" {
  provider = aws.provisionassessment

  for_each = toset(var.private_subnet_cidr_blocks)
  lifecycle {
    ignore_changes = [vpc]
  }

  # Note that this code assumes that we are using /24 blocks.
  name = format(
    "%s.%s.%s.in-addr.arpa.",
    element(split(".", each.value), 2),
    element(split(".", each.value), 1),
    element(split(".", each.value), 0),
  )
  vpc {
    vpc_id = aws_vpc.assessment.id
  }
}

# Associate assessment VPC with Shared Services Route53 (private DNS)
# zone
resource "aws_route53_vpc_association_authorization" "assessment_private" {
  provider = aws.dns_sharedservices

  vpc_id  = aws_vpc.assessment.id
  zone_id = data.terraform_remote_state.sharedservices_networking.outputs.private_zone.id
}

resource "aws_route53_zone_association" "assessment_private" {
  provider = aws.provisionassessment

  vpc_id  = aws_route53_vpc_association_authorization.assessment_private.vpc_id
  zone_id = aws_route53_vpc_association_authorization.assessment_private.zone_id
}
