output "function_id" {
    value = aws_sfn_state_machine.machine.id
    description = "The ID of the state machine that was created."
}
output "function_arn" {
    value = aws_sfn_state_machine.machine.arn
    description = "The Amazon Resource Name (ARN) of the state machine that was created."
}
output "function_standard_policies" {
    value = { "executor" = data.aws_iam_policy_document.standard_executor_policy.json,
              "invoker" = data.aws_iam_policy_document.standard_invoker_policy.json }
    description = "Standard IAM policies for the Step Function in JSON format"
}