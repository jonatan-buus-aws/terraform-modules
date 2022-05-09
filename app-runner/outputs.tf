output "app_runner_service" {
    value = { id = aws_apprunner_service.service.service_id,
              arn = aws_apprunner_service.service.arn,
              domain = aws_apprunner_service.service.service_url }
    description = "The details for the created App Runner Service"
}
output "app_runner_custom_domains" {
    value = { for k, v in aws_apprunner_custom_domain_association.domain : v.dns_target => [ for val in v.certificate_validation_records : val.value ] }
    description = "The custom domains associated with the created App Runner Service"
}
output "app_runner_standard_policies" {
    value = { "ecr" = data.aws_iam_policy_document.standard_ecr_policy.json,
              "instance" = data.aws_iam_policy_document.standard_instance_policy.json }
    description = "Standard IAM policies for a App Runner in JSON format"
}