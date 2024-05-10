# Private DNS A record for Nessus instance
resource "aws_route53_record" "nessus_A" {
  count    = lookup(var.operations_instance_counts, "nessus", 0)
  provider = aws.provisionassessment

  name    = "nessus${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.nessus[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
