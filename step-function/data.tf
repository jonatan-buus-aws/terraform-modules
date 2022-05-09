data "aws_iam_policy_document" "standard_executor_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "states.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "standard_invoker_policy" {

    statement {
        actions = [ "states:StartSyncExecution" ]
        effect  = "Allow"

        resources = [ aws_sfn_state_machine.machine.arn ]
    }
}
data "aws_iam_role" "function_role" {
    depends_on = [ var.function_role ]

    name = var.function_role
}