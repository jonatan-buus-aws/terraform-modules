data "aws_iam_policy_document" "standard_executor_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "apigateway.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "standard_invoker_policy" {

    statement {
        actions = [ "execute-api:Invoke" ]
        effect = "Allow"

        resources = [ "${aws_api_gateway_rest_api.api.execution_arn}/*" ]
    }
}
data "aws_iam_role" "api_gateway_role" {
    depends_on = [ var.apigw_role ]

    name = var.apigw_role
}
# See: https://stackoverflow.com/questions/44605228/aws-api-gateway-with-step-function/46905904#46905904
# See: https://github.com/jvillane/aws-sam-step-functions-lambda
# See: https://stackoverflow.com/questions/42914487/how-to-invoke-an-aws-step-function-using-api-gateway
# See: https://blog.shikisoft.com/trigger-aws-step-functions-by-api-gateway-calls/
# See: https://github.com/aws-samples/example-step-functions-integration-api-gateway
data "template_file" "openapi" {
    depends_on = [ var.apigw_api_name, var.apigw_domain, var.apigw_uris ]

    template = jsonencode(yamldecode(file("${path.module}/openapi.yaml") ) )
    vars = {
        apigw_api_name = var.apigw_api_name
        apigw_domain = var.apigw_domain
        apigw_json_request_template = replace(replace(data.template_file.request.rendered, "\"", "\\\""), "/[\r|\n]/", "")
        apigw_json_response_template = replace(replace(file("${path.module}/response.tpl"), "\"", "\\\""), "/[\r|\n]/", "")
        initalize_payment_url = var.apigw_uris.initalize_payment
        get_payment_url = var.apigw_uris.get_payment
        authorize_payment_step_function_arn = var.apigw_uris.authorize_payment
        aws_region = data.aws_region.region.name
        credentials = data.aws_iam_role.api_gateway_role.arn
    }
}
data "template_file" "request" {
    depends_on = [ var.apigw_api_name, var.apigw_domain, var.apigw_uris ]

    template = file(local.apigw_json_request_template)

    vars = {
        apigw_api_name = var.apigw_api_name
        apigw_domain = var.apigw_domain
        initalize_payment_url = var.apigw_uris.initalize_payment
        get_payment_url = var.apigw_uris.get_payment
        authorize_payment_step_function_arn = var.apigw_uris.authorize_payment
        aws_region = data.aws_region.region.name
        credentials = data.aws_iam_role.api_gateway_role.arn
    }
}
data "aws_region" "region" {}

data "aws_route53_zone" "zone" {
    depends_on = [ var.apigw_domain ]
    
    count = var.apigw_domain == "" ? 0 : 1

    name = regex("\\.(?P<domain>.+$)", var.apigw_domain).domain
    private_zone = false
}