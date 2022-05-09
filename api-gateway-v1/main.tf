locals {
	apigw_json_request_template = var.apigw_json_request_template == "" ? "${path.module}/request.tpl" : var.apigw_json_request_template

}
resource "local_file" "test" {
    content = data.template_file.openapi.rendered
    filename = "${path.module}/openapi_rendered.json"
}

resource "aws_api_gateway_rest_api" "api" {
	name = var.apigw_api_name
	body = data.template_file.openapi.rendered
}

resource "aws_api_gateway_deployment" "deployment" {
	rest_api_id = aws_api_gateway_rest_api.api.id

	triggers = {
		redeployment = sha1(aws_api_gateway_rest_api.api.body)
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_api_gateway_stage" "stage" {
	deployment_id = aws_api_gateway_deployment.deployment.id
	rest_api_id = aws_api_gateway_rest_api.api.id
	stage_name = var.apigw_stage_name
	xray_tracing_enabled = true
}

resource "aws_acm_certificate" "certificate" {
	count = var.apigw_domain == "" ? 0 : 1

	domain_name = var.apigw_domain
	validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
	for_each = var.apigw_domain == "" ? { } : {
		for dvo in aws_acm_certificate.certificate.0.domain_validation_options : dvo.domain_name => {
			name = dvo.resource_record_name
			record = dvo.resource_record_value
			type = dvo.resource_record_type
		}
	}

	allow_overwrite = true
	name = each.value.name
	records = [ each.value.record ]
	ttl = 60
	type = each.value.type
	zone_id = data.aws_route53_zone.zone.0.id
}
resource "aws_acm_certificate_validation" "validation" {
	count = var.apigw_domain == "" ? 0 : 1

	certificate_arn = aws_acm_certificate.certificate.0.arn
	validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

resource "aws_api_gateway_domain_name" "domain" {
	count = var.apigw_domain == "" ? 0 : 1

	certificate_arn = aws_acm_certificate_validation.validation.0.certificate_arn
	domain_name = var.apigw_domain
	security_policy = "TLS_1_2"
}

# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "record" {
	count = var.apigw_domain == "" ? 0 : 1

	name = aws_api_gateway_domain_name.domain.0.domain_name
	type = "A"
	zone_id = data.aws_route53_zone.zone.0.id

	alias {
		evaluate_target_health = true
		name = aws_api_gateway_domain_name.domain.0.cloudfront_domain_name
		zone_id = aws_api_gateway_domain_name.domain.0.cloudfront_zone_id
	}
}
resource "aws_api_gateway_base_path_mapping" "mapping" {
	count = var.apigw_domain == "" ? 0 : 1

	api_id = aws_api_gateway_rest_api.api.id
	stage_name = aws_api_gateway_stage.stage.stage_name
	domain_name = aws_api_gateway_domain_name.domain.0.domain_name
}