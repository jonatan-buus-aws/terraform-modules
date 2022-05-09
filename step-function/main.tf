# See: https://aws.amazon.com/blogs/compute/introducing-amazon-api-gateway-service-integration-for-aws-step-functions/
# See: https://aws.amazon.com/blogs/compute/new-synchronous-express-workflows-for-aws-step-functions/
resource "aws_sfn_state_machine" "machine" {
	name = var.function_name
	role_arn = data.aws_iam_role.function_role.arn
	type = "EXPRESS"

	definition = var.function_definition
	logging_configuration {
		include_execution_data = true
		level = "ALL"
		log_destination = "arn:aws:logs:us-east-1:996046942922:log-group:/aws/vendedlogs/states/authorize-payment-integration-Logs:*"
	}
}