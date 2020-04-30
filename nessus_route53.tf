# Private DNS A record for Nessus instance
resource "aws_route53_record" "nessus_A" {
  count    = lookup(var.operations_instance_counts, "nessus", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "nessus${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.nessus[count.index].private_ip]
}
