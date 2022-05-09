resource "random_id" "id" {
	prefix = "${var.lb_name}-"
	byte_length = 8
}

resource "aws_lb" "load_balancer" {
	name = random_id.id.hex
	load_balancer_type = var.lb_type
	internal = var.lb_internal

	security_groups = var.lb_security_groups
	subnets = var.lb_subnets
	
	access_logs {
		bucket = var.lb_log_bucket
		prefix = var.lb_name
		enabled = true
	}

	tags = var.lb_tags
}

resource "aws_lb_target_group" "target_group" {
	name = "${var.lb_name}-tg"
	port = 80
	protocol = "HTTP"
	vpc_id = var.lb_vpc
}

resource "aws_lb_listener" "listener" {
	load_balancer_arn = aws_lb.load_balancer.arn
	port = "443"
	protocol = "HTTPS"
	ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
	certificate_arn = var.lb_domain_name == "" ? aws_acm_certificate.self_signed.0.arn : aws_acm_certificate.certificate.0.arn

	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.target_group.arn
	}
}

resource "aws_lb_listener_rule" "listener_rule" {
	listener_arn = aws_lb_listener.listener.arn
	priority = 100

	action {
		type = "forward"
		target_group_arn = aws_lb_target_group.target_group.arn
	}
	condition {
		host_header {
			values = [ var.lb_domain_name == "" ? aws_lb.load_balancer.dns_name : var.lb_domain_name ]
		}
	}
}

resource "aws_acm_certificate" "certificate" {
	count = var.lb_domain_name == "" ? 0 : 1

	domain_name = var.lb_domain_name
	validation_method = "DNS"

	tags = var.lb_tags

	lifecycle {
		create_before_destroy = true
	}
}

resource "tls_private_key" "private_key" {
	count = var.lb_domain_name == "" ? 1 : 0

	algorithm = "RSA"
}

resource "tls_self_signed_cert" "certificate" {
	count = var.lb_domain_name == "" ? 1 : 0

	key_algorithm   = "RSA"
	private_key_pem = tls_private_key.private_key.0.private_key_pem

	subject {
		common_name = aws_lb.load_balancer.dns_name
		organization = "AWS ALB"
	}
	dns_names = [ aws_lb.load_balancer.dns_name ]

	validity_period_hours = 24*365

	allowed_uses = [
		"key_encipherment",
		"digital_signature",
		"server_auth",
	]
}

resource "aws_acm_certificate" "self_signed" {
	count = var.lb_domain_name == "" ? 1 : 0
	
	private_key = tls_private_key.private_key.0.private_key_pem
	certificate_body = tls_self_signed_cert.certificate.0.cert_pem
}