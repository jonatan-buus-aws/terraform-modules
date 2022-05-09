variable "apigw_repository_name" {
    type = string
    description = "The name of the created image repository."
}

variable "apigw_enable_mutable_images" {
    type = bool
    default = true
    description = "Flag indicating whether images may be overwritten or not. Defaults to \"true\"."
}
variable "apigw_encryption_type" {
    type = string
    default = "AES256"
    description = "The encryption type to use for the created repository. Valid values are \"AES256\" or \"KMS\". Defaults to \"AES256\"."
}
variable "apigw_encryption_key" {
    type = string
    default = null
    description = "The Amazon Resource Name (ARN) of the KMS key to use when \"apigw_encryption_type\" is \"KMS\". Default to the AWS managed key for ECR."
}
variable "apigw_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created image repository."
}