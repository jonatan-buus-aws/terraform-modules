output "iam_group" {
	value = { id = aws_iam_group.group.unique_id,
			  arn = aws_iam_group.group.arn }
	description = "An object representing the created IAM group"
}
output "iam_users" {
	value = { for k, v in aws_iam_user.user : k => { id = v.unique_id,
													 name = v.name,
													 arn = v.arn,
													 login = contains(keys(aws_iam_user_login_profile.login), k) == true ? { fingerprint = aws_iam_user_login_profile.login[k].key_fingerprint,
												  																			 encrypted_password = aws_iam_user_login_profile.login[k].encrypted_password,
																															 password = contains(keys(data.local_file.user_login_keybase_keys), k) == true ? data.local_file.user_login_keybase_keys[k].content : null } : null,
													 access_key = contains(keys(aws_iam_access_key.access_key), k) == true ? { fingerprint = aws_iam_access_key.access_key[k].key_fingerprint,
												  																			   encrypted_secret = aws_iam_access_key.access_key[k].encrypted_secret,
																															   secret = contains(keys(data.local_file.user_access_keybase_keys), k) == true ? data.local_file.user_access_keybase_keys[k].content : null } : null,
													 ssh_key_fingerprint = contains(keys(aws_iam_user_ssh_key.ssh_key), k) == true ? aws_iam_user_ssh_key.ssh_key[k].fingerprint : null } }
    description = "Map of objects representing the created IAM users using the user's name as the key"
}
output "iam_created_policies" {
	value = { for k, v in aws_iam_policy.policy : k => { id = v.policy_id,
														 name = v.name,
														 arn = v.arn } }
    description = "Map of objects representing the created IAM policies using the policy's name as the key"
}
output "iam_standard_policies" {
    value = { "read_only" = data.aws_iam_policy_document.read_only.json,
        	  "admin" = data.aws_iam_policy_document.admin.json,
			  "ec2_instance_profile" = data.aws_iam_policy_document.ec2_instance_profile.json }
    description = "The list of generated standard IAM policies: \"read_only\", \"admin\" or \"ec2_instance_profile\" in JSON format"
}