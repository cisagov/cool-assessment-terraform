# Private DNS A record for Windows instances
resource "aws_route53_record" "windows_A" {
  count    = lookup(var.operations_instance_counts, "windows", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "windows${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.windows[count.index].private_ip]
}
