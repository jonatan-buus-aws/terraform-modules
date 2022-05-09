variable "iam_group" {
    type = object({ name = string,
                    path = string })
    default = { name = null,
                path = "/" }
    description = "The properties of the created IAM group. The path defaults to: /[GROUP NAME]/ where as the name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. Group names are not distinguished by case. For example, you cannot create groups named both \"ADMINS\" and \"admins\""
}

variable "iam_temp_path" {
    type = string
    default = ""
    description = "The absolute path to a temporary directory where Terraform may write files. Defaults to current working directory."
}

variable "iam_users" {
    type = list(object({ username = string,
                         path = string,
                         login_key = string,
                         access_key = string,
                         ssh_public_key = string,
                         ssh_key_format = string }) )
    default = [ ]
    description = "List of object representing the users that will be created and associated with the IAM group."
}
variable "iam_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created IAM policies and IAM users"
}

variable "iam_policies" {
    type = list(object({ name = string,
                         description = string,
                         path = string,
                         policy = string }) )
    default = [ ]
    description = "List of policies that will be created and associated with the created IAM group."
}