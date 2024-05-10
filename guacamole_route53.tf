resource "aws_route53_record" "guacamole_A" {
  provider = aws.dns_sharedservices

  name    = "guac.${local.assessment_account_name_base}.${var.cool_domain}"
  records = [aws_instance.guacamole.private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = local.cool_dns_private_zone.zone_id
}

resource "aws_route53_record" "guacamole_PTR" {
  provider = aws.provisionassessment

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
  records = [
    "guac.${local.assessment_account_name_base}.${var.cool_domain}"
  ]
  ttl     = var.dns_ttl
  type    = "PTR"
  zone_id = aws_route53_zone.private_subnet_reverse[var.private_subnet_cidr_blocks[0]].id
}
