output "apigw_id" {
    value = aws_api_gateway_rest_api.api.id
    description = "The unique ID of the created API Gateway"
}
output "apigw_arn" {
    value = aws_api_gateway_rest_api.api.execution_arn
    description = "The full Amazon Resource Name (ARN) of the created API Gateway."
}
output "apigw_domain" {
    value = var.apigw_domain == "" ? "${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.region.name}.amazonaws.com" : aws_api_gateway_domain_name.domain.0.domain_name
    description = "The public domain name of the created API Gateway."
}
output "apigw_endpoint" {
    value = "${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.region.name}.amazonaws.com"
    description = "The internal end-point for the created API Gateway."
}
output "apigw_standard_policies" {
    value = { "executor" = data.aws_iam_policy_document.standard_executor_policy.json,
              "invoker" = data.aws_iam_policy_document.standard_invoker_policy.json }
    description = "Standard IAM policies for an API Gateway in JSON format"
}