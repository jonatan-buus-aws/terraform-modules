module "common" {
	source = "../common"
}

locals {
	keybase_regex = "^keybase:(?P<username>[a-z0-9_]+)#(?P<fingerprint>[a-z0-9]+)$"
	keybase_key_separator = "\n\n-----"
	pgp_regex = "(?P<pgp_key>.+)=.{4}-----END PGP PUBLIC KEY BLOCK-----$"
	keybase_normalization_regex = "^keybase:.+#[a-zA-z0-9]+$"

	user_logins = { for v in var.iam_users : v.username => v if v.login_key != "" }
	user_access_keys = { for v in var.iam_users : v.username => v if v.access_key != "" }
	user_ssh_keys = { for v in var.iam_users : v.username => v if v.ssh_public_key != "" }
	user_login_keybase_keys = { for k, v in local.user_logins : k => regexall(local.keybase_regex, format("%s%s", v.login_key, length(regexall(local.keybase_normalization_regex, v.login_key) ) == 0 ? "#1" : "") )[0] if length(regexall(local.keybase_regex, format("%s%s", v.login_key, length(regexall(local.keybase_normalization_regex, v.login_key) ) == 0 ? "#1" : "") ) ) > 0 }
	user_access_keybase_keys = { for k, v in local.user_access_keys : k => regexall(local.keybase_regex, format("%s%s", v.access_key, length(regexall(local.keybase_normalization_regex, v.access_key) ) == 0 ? "#1" : "") )[0] if length(regexall(local.keybase_regex, format("%s%s", v.access_key, length(regexall(local.keybase_normalization_regex, v.access_key) ) == 0 ? "#1" : "") ) ) > 0 }

	temp_path = var.iam_temp_path == "" ? path.cwd : var.iam_temp_path
	
	windows_decryption_command = "echo %s > ${local.temp_path}/%s_base64_%s_source.txt | certutil -decode ${local.temp_path}/%s_base64_%s_source.txt %s_base64_%s_target.txt | keybase pgp decrypt --infile ${local.temp_path}/%s_base64_%s_target.txt --outfile ${local.temp_path}/%s_decrypted_%s_key.txt"
	linux_decryption_command = "echo %s | base64 --decode | keybase pgp decrypt --outfile ${local.temp_path}/%s_decrypted_%s_key.txt"
	decryption_command = module.common.os == "windows" ? local.windows_decryption_command : local.linux_decryption_command

	windows_cleanup_command = "cd ${local.temp_path} && DEL %s_base64_%s_source.txt && DEL %s_base64_%s_target.txt"
	linux_cleanup_command = replace(" && DEL ", " && rm ", local.windows_cleanup_command)
	cleanup_command = module.common.os == "windows" ? local.windows_cleanup_command : local.linux_cleanup_command
	
	group_path = var.iam_group.path == "" ? "/${var.iam_group.name}/" : var.iam_group.path
}

resource "aws_iam_group" "group" {
	name = var.iam_group.name
	path = local.group_path
}

resource "aws_iam_user" "user" {
	for_each = { for v in var.iam_users : v.username => v }

	name = each.value.username
	path = each.value.path == "" ? "${local.group_path}users/" : each.value.path
	tags = var.iam_tags

	force_destroy = true
}

# Creates login profiles for the listed IAM users.
# The resource will used the PGP key that was retrieved from www.keybase.io if available and automatically handle the following scenarios
#	- PGP key stored in Keybase specified using the key's fingerprint by setting login_key = keybase:[KEYBASE USERNAME]#[40 CHARACTER FINGERPRINT]
#	- PGP key stored in Keybase specified using the key's position when retrieving all PGP keys for the user by setting login_key = keybase:[KEYBASE USERNAME]#[NUMERIC POSITION STARTING FROM 1]
#	- Use default PGP key stored in Keybase
# PGP keys retrieved from Keybase are formatted into the format expected by Terraform, that is:
#	- All headers and footers are removed
#	- All newlines are removed
# See: https://jonathan.bergknoff.com/journal/terraforming-aws-iam-users/
resource "aws_iam_user_login_profile" "login" {
	for_each = local.user_logins

	user = aws_iam_user.user[each.value.username].name
	pgp_key = contains(keys(local.user_login_keybase_keys), each.key) == true ? regex(local.pgp_regex, replace(split("\n\n", split(local.keybase_key_separator, data.http.user_login_keybase_keys[each.key].body)[length(local.user_login_keybase_keys[each.key].fingerprint) > 5 ? 0 : local.user_login_keybase_keys[each.key].fingerprint - 1])[1], "\n", "") ).pgp_key : each.value.login_key
}

# Creates API access keys for the listed IAM users.
# The resource will used the PGP key that was retrieved from www.keybase.io if available and automatically handle the following scenarios
#	- PGP key stored in Keybase specified using the key's fingerprint by setting access_key = keybase:[KEYBASE USERNAME]#[40 CHARACTER FINGERPRINT]
#	- PGP key stored in Keybase specified using the key's position when retrieving all PGP keys for the user by setting access_key = keybase:[KEYBASE USERNAME]#[NUMERIC POSITION STARTING FROM 1]
#	- Use default PGP key stored in Keybase
# PGP keys retrieved from Keybase are formatted into the format expected by Terraform, that is:
#	- All headers and footers are removed
#	- All newlines are removed
# See: https://jonathan.bergknoff.com/journal/terraforming-aws-iam-users/
resource "aws_iam_access_key" "access_key" {
	for_each = local.user_access_keys
	
	user = aws_iam_user.user[each.value.username].name
	pgp_key = contains(keys(local.user_access_keybase_keys), each.key) == true ? regex(local.pgp_regex, replace(split("\n\n", split(local.keybase_key_separator, data.http.user_access_keybase_keys[each.key].body)[length(local.user_access_keybase_keys[each.key].fingerprint) > 5 ? 0 : local.user_access_keybase_keys[each.key].fingerprint - 1])[1], "\n", "") ).pgp_key : each.value.access_key
}

resource "aws_iam_user_ssh_key" "ssh_key" {
	for_each = local.user_ssh_keys

	username = aws_iam_user.user[each.value.username].name
	encoding = upper(each.value.ssh_key_format)
	public_key = each.value.ssh_public_key
}

resource "aws_iam_policy" "policy" {
	for_each = { for v in var.iam_policies : v.name => v }

	name = each.value.name
	description = each.value.description
	path = each.value.path == "" ? "${local.group_path}policies/" : each.value.path

	# Terraform's "jsonencode" function converts a
	# Terraform expression result to valid JSON syntax.
	policy = each.value.policy
	tags = var.iam_tags
}

resource "aws_iam_group_policy_attachment" "attachment" {
	for_each = aws_iam_policy.policy

	group = aws_iam_group.group.name
	policy_arn = each.value.arn
}

# See: https://discuss.hashicorp.com/t/aws-iam-access-key-encrypted-secret-base64-decode/14531
resource "null_resource" "decrypt_login_keys" {
	depends_on = [ aws_iam_user_login_profile.login ]
	for_each = local.user_login_keybase_keys

	# Changes to the encrypted password requires re-provisioning
	triggers = {
		encrypted_password = aws_iam_user_login_profile.login[each.key].encrypted_password
	}

	# Decrypt the login key created using keybase for the user
	provisioner "local-exec" {
		command = format(local.decryption_command, aws_iam_user_login_profile.login[each.key].encrypted_password, each.key, "login", each.key, "login", each.key, "login", each.key, "login", each.key, "login")
	}
}
resource "null_resource" "decrypt_access_keys" {
	depends_on = [ aws_iam_access_key.access_key ]
	for_each = local.user_access_keybase_keys

	# Changes to the encrypted secret requires re-provisioning
	triggers = {
		encrypted_secret = aws_iam_access_key.access_key[each.key].encrypted_secret
	}

	# Decrypt the access key created using keybase for the user
	provisioner "local-exec" {
		command = format(local.decryption_command, aws_iam_access_key.access_key[each.key].encrypted_secret, each.key, "access", each.key, "access", each.key, "access", each.key, "access", each.key, "access")
	}
}

# Remove temporary files used during decryption of the login key
resource "local_file" "cleanup_login_keys" {
	for_each = data.local_file.user_login_keybase_keys

	content = ""
    filename = each.value.filename
	
	provisioner "local-exec" {
		command = format(local.cleanup_command, each.key, "login", each.key, "login")
	}
}

# Remove temporary files used during decryption of the access key
resource "local_file" "cleanup_access_keys" {
	for_each = data.local_file.user_access_keybase_keys

	content = ""
    filename = each.value.filename

	provisioner "local-exec" {
		command = format(local.cleanup_command, each.key, "access", each.key, "access")
	}
}