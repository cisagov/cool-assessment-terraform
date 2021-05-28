# Private DNS A record for Gophish instances
resource "aws_route53_record" "gophish_A" {
  count    = lookup(var.operations_instance_counts, "gophish", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "gophish${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.gophish[count.index].private_ip]
}
