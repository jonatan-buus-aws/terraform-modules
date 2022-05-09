output "iam_role" {
	value = { id = aws_iam_role.role.unique_id,
			  arn = aws_iam_role.role.arn,
			  name = aws_iam_role.role.name }
	description = "An object representing the created IAM role"
}
output "iam_created_policies" {
	value = { for k, v in aws_iam_policy.policy : k => { id = v.policy_id,
														 name = v.name,
														 arn = v.arn } }
    description = "Map of objects representing the created IAM policies using the policy's name as the key"
}
output "iam_standard_policies" {
    value = { "eks_cluster" = data.aws_iam_policy_document.eks_cluster_policy.json,
			  "eks_node_group" = data.aws_iam_policy_document.eks_node_group_policy.json,
			  "eks_service_account" = data.aws_iam_policy_document.eks_service_account_policy.json,
			  "cloudwatch" = data.aws_iam_policy_document.cloudwatch_policy.json,
			  "api_gateway" = data.aws_iam_policy_document.api_gateway_policy.json,
			  "step_function" = data.aws_iam_policy_document.step_function_policy.json }
    description = "The list of generated standard IAM policies: \"cloudwatch\", \"eks_cluster\", \"eks_node_group\" and  \"eks_service_account\" in JSON format"
}