resource "aws_apigatewayv2_api" "gateway" {
	name = var.apigw_name
	description = var.apigw_description
	protocol_type = var.apigw_protocol
	version = var.apigw_version
	disable_execute_api_endpoint = true

	dynamic "cors_configuration" {
		for_each = length(keys(var.apigw_cors_config) ) > 0 && var.apigw_protocol == "HTTP" ? [ var.apigw_cors_config ] : [ ]

		content {
			allow_credentials = lookup(cors_configuration.value, "allow_credentials", null)
			allow_headers = lookup(cors_configuration.value, "allow_headers", null)
			allow_methods  = lookup(cors_configuration.value, "allow_methods", null)
			allow_origins = lookup(cors_configuration.value, "allow_origins", null)
			expose_headers = lookup(cors_configuration.value, "expose_headers", null)
			max_age = lookup(cors_configuration.value, "max_age", null)
		}
	}

	tags = var.apigw_tags
}

resource "aws_apigatewayv2_authorizer" "authorizer" {
	api_id = aws_apigatewayv2_api.gateway.id
	authorizer_type = "JWT"
	identity_sources = [ "$request.header.Authorization" ]
	name = "${aws_apigatewayv2_api.gateway.name}-authorizer"

	jwt_configuration {
		audience = [ "example" ]
		issuer = "https://${aws_cognito_user_pool.example.endpoint}"
	}
	tags = var.apigw_tags
}

# See: https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-http.html
resource "aws_apigatewayv2_integration" "integration" {
	api_id = aws_apigatewayv2_api.gateway.id
	credentials_arn  = aws_iam_role.example.arn
	description = "Integration for ${aws_apigatewayv2_api.gateway.name}"
	integration_type = var.api_gw_integration.type
	integration_subtype = var.api_gw_integration.type == "AWS_PROXY" ? var.api_gw_integration.subtype : null
	integration_method = var.api_gw_integration.method
	integration_uri = var.api_gw_integration.uri
	timeout_milliseconds = var.api_gw_integration.timeout * 1000
	
	connection_type = "INTERNET"

	dynamic "tls_config" {
		for_each = var.apigw_protocol == "HTTP" ? [ var.apigw_domain_name ] : [ ]

		content {
			server_name_to_verify = tls_config.value
		}
	}
	tls_config {
		server_name_to_verify = var.apigw_domain_name
	}

	request_parameters = var.apigw_request.parameter_mappings
	request_templates = var.apigw_request.velocity_templates

	dynamic "response_parameters" {
		for_each = var.apigw_response.parameter_mappings

		content {
			status_code = response_parameters.key
			mappings = response_parameters.value
		}
	}
}
resource "aws_apigatewayv2_integration_response" "response" {
	api_id  = aws_apigatewayv2_api.gateway.id
	integration_id = aws_apigatewayv2_integration.integration.id
	integration_response_key = "/200/"
	response_templates = var.apigw_response.velocity_templates
}
resource "aws_apigatewayv2_route" "route" {
	api_id = aws_apigatewayv2_api.gateway.id
	route_key = "ANY /example/{proxy+}"

	target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}


resource "aws_apigatewayv2_domain_name" "domain" {
	domain_name = var.apigw_domain_name

	domain_name_configuration {
		certificate_arn = var.apigw_certificate
		endpoint_type = "REGIONAL"
		security_policy = "TLS_1_2"
	}
	tags = var.apigw_tags
}
resource "aws_apigatewayv2_api_mapping" "mapping" {
	api_id = aws_apigatewayv2_api.gateway.id
	domain_name = aws_apigatewayv2_domain_name.domain.id
	stage = aws_apigatewayv2_stage.stage.id
}
# See: https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-stages.html
resource "aws_apigatewayv2_stage" "stage" {
	api_id = aws_apigatewayv2_api.gateway.id
	name = "dev"
}