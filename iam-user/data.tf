locals {
    keybase_url = "https://keybase.io/%s/pgp_keys.asc%s"
}
data "http" "user_login_keybase_keys" {
	for_each = local.user_login_keybase_keys
	
	url = format(local.keybase_url, each.value.username, length(each.value.fingerprint) > 5 ? "?fingerprint=${each.value.fingerprint}" : "")
}

data "http" "user_access_keybase_keys" {
	for_each = local.user_access_keybase_keys
	
	url = format(local.keybase_url, each.value.username, length(each.value.fingerprint) > 5 ? "?fingerprint=${each.value.fingerprint}" : "")
}

data "local_file" "user_login_keybase_keys" {
	for_each = null_resource.decrypt_login_keys
	
    filename = "${local.temp_path}/${each.key}_decrypted_login_key.txt"
}
data "local_file" "user_access_keybase_keys" {
	for_each = null_resource.decrypt_access_keys
	
    filename = "${local.temp_path}/${each.key}_decrypted_access_key.txt"
}

data "aws_iam_policy_document" "read_only" {
    statement {
        actions = [
            "iam:Get*",
            "iam:List*",
            "iam:Generate*"
        ]
        resources = ["*"]
        effect = "Allow"
    }
}
data "aws_iam_policy_document" "admin" {
    statement {
        actions = [
            "iam:*"
        ]
        resources = ["*"]
        effect = "Allow"
    }
}

data "aws_iam_policy_document" "ec2_instance_profile" {
    statement {
        actions = [
            "ec2:RunInstances",
            "ec2:AssociateIamInstanceProfile",
            "ec2:ReplaceIamInstanceProfileAssociation"
        ]
        resources = [ "*" ]
        effect = "Allow"
    }
    statement {
        actions = [ "iam:PassRole" ]
        resources = [ "*" ]
        effect = "Allow"
    }
}