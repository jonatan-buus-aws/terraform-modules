locals {
	iam_policies = { for v in var.iam_policies : v.name => v }
	iam_role_description = var.iam_role_description == "" ? length(local.iam_policies) == 0 ? "Role with no policies attached" : "Role with policies: ${join(keys(local.iam_policies), ", ")} attached" : var.iam_role_description
}

resource "aws_iam_role" "role" {
	name = var.iam_role_name
	assume_role_policy = var.iam_assume_role_policy
	description = local.iam_role_description
	path = var.iam_role_path
}

resource "aws_iam_policy" "policy" {
	for_each = local.iam_policies

	name = each.value.name
	description = each.value.description
	path = each.value.path == "" ? "${var.iam_role_path}policies/" : each.value.path

	# Terraform's "jsonencode" function converts a
	# Terraform expression result to valid JSON syntax.
	policy = each.value.policy
	tags = var.iam_tags
}

resource "aws_iam_role_policy_attachment" "created" {
	for_each = aws_iam_policy.policy

	role = aws_iam_role.role.name
	policy_arn = each.value.arn
}
resource "aws_iam_role_policy_attachment" "existing" {
	for_each = toset(var.iam_policy_attachments)

	role = aws_iam_role.role.name
	policy_arn = each.value
}