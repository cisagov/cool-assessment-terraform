resource "aws_route53_record" "guacamole_A" {
  provider = aws.dns_sharedservices

  zone_id = local.cool_dns_private_zone.zone_id
  name    = "guac.${local.assessment_account_name_base}.${var.cool_domain}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.guacamole.private_ip]
}

resource "aws_route53_record" "guacamole_PTR" {
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.private_subnet_reverse[var.private_subnet_cidr_blocks[0]].id
  # Terraform and/or AWS appends the reverse zone name if you specify
  # just enough of the record name to "fill in" the rest of the PTR record.
  # For example, if this record were for the IP 10.11.12.13, going into the
  # reverse zone with name "12.11.10.in-addr-arpa.", then you could provide
  # the entire record name ("13.12.11.10.in-addr.arpa.") or just the last
  # octet ("13").  If you do the latter, then look at the corresponding
  # Route53 record in the AWS console, you can see that the
  # ".12.11.10.in-addr.arpa." part of the name has been automatically added.
  #
  # This allows us to create PTR records more succinctly.
  name = format(
    "%s",
    element(split(".", aws_instance.guacamole.private_ip), 3)
  )

  type = "PTR"
  ttl  = var.dns_ttl
  records = [
    "guac.${local.assessment_account_name_base}.${var.cool_domain}"
  ]
}
