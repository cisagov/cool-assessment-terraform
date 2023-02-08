# Private DNS A record for Egress-Assess instances
resource "aws_route53_record" "egressassess_A" {
  count    = lookup(var.operations_instance_counts, "egressassess", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "egressassess${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.egressassess[count.index].private_ip]
}
