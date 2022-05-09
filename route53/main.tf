locals {
	parent_zone = length(split(".", var.route53_zone_domain) ) > 2 ? regex("\\.(?P<domain>.+$)", var.route53_zone_domain).domain : ""
}
resource "aws_route53_delegation_set" "delegation" {
	count = var.route53_vpc == "" ? 1 : 0

	reference_name = var.route53_zone_domain
}
resource "aws_route53_zone" "zone" {
	name = var.route53_zone_domain
	comment = var.route53_description == "" ? "DNS zone for ${var.route53_zone_domain}" : var.route53_description

	# Create private zone
	dynamic "vpc" {
		for_each = var.route53_vpc == "" ? [ ] : [ var.route53_vpc ]

		content {
			vpc_id = vpc.value
		}
	}
	delegation_set_id = var.route53_vpc == "" ? aws_route53_delegation_set.delegation.0.id : null

	tags = var.route53_tags
}

resource "aws_route53_record" "ns" {
	count = local.parent_zone == "" || var.route53_vpc != "" ? 0 : 1

	zone_id = data.aws_route53_zone.zone.0.id
	name = var.route53_zone_domain
	type = "NS"
	ttl = "30"
	records = aws_route53_zone.zone.name_servers
}

resource "aws_route53_record" "record" {
	for_each = { for v in var.route53_dns_records : v.name => v }

	zone_id = aws_route53_zone.zone.zone_id
	name = each.value.name
	type = each.value.type
	ttl = "30"
	records = each.value.records
}