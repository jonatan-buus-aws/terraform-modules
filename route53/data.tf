data "aws_route53_zone" "zone" {
    depends_on = [ var.route53_depends_on, var.route53_zone_domain ]
    
	count = local.parent_zone == "" ? 0 : 1

    name = local.parent_zone
}