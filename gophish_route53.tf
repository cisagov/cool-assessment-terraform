# Private DNS A record for Gophish instances
resource "aws_route53_record" "gophish_A" {
  count    = lookup(var.operations_instance_counts, "gophish", 0)
  provider = aws.provisionassessment

  name    = "gophish${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.gophish[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
