output "route53_zone_id" {
    value = aws_route53_zone.zone.id
    description = "The ID of the created DNS zone"
}
output "route53_zone_domain" {
    value = aws_route53_zone.zone.name
    description = "The domain name of the created DNS zone"
}
output "route53_nameservers" {
    value = aws_route53_zone.zone.name_servers
    description = "List of nameservers for the created DNS zone"
}