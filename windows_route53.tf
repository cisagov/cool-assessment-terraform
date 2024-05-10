# Private DNS A record for Windows instances
resource "aws_route53_record" "windows_A" {
  count    = lookup(var.operations_instance_counts, "windows", 0)
  provider = aws.provisionassessment

  name    = "windows${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.windows[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
