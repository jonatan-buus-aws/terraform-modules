variable "iam_role_name" {
    type = string
    description = "The name of the IAM role that will be created"
}
variable "iam_assume_role_policy" {
    type = string
    description = "The policy document as a JSON formatted string that grants an entity permission to assume the created role."
}

variable "iam_role_description" {
    type = string
    default = ""
    description = "The description of the IAM role that will be created. Defaults to an informative listing of the provided policy names will be constructed"
}
variable "iam_role_path" {
    type = string
    default = "/"
    description = "The path in which the IAM role will be created. Defaults to \"/roles/\""
}
variable "iam_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created IAM policies and IAM roles"
}

variable "iam_policies" {
    type = list(object({ name = string,
                         description = string,
                         path = string,
                         policy = string }) )
    default = [ ]
    description = "List of new policies that will be created and associated with the created IAM role."
}
variable "iam_policy_attachments" {
    type = list(string)
    default = [ ]
    description = "List of Amazon Resource Names (ARNs) for existing policies that will be associated with the created IAM role."
}