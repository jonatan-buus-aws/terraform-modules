variable "pgbouncer_database_host" {
    type = string
    description = "The hostname of the PostGreSQL cluster"
}
variable "pgbouncer_port" {
    type = number
    default = 6432
    description = "The port number that pgBouncer listens on"
}
variable "pgbouncer_pods" {
    type = number
    default = 3
    description = "The number of pgBouncer pods that will be created"
}
variable "pgbouncer_depends_on" {
    type = any
    default = null
    description = "Declares the PgBouncer module's depdendencies other modules"
}

variable "ecr_enable_mutable_images" {
    type = bool
    default = true
    description = "Flag indicating whether images may be overwritten or not. Defaults to \"true\"."
}
variable "ecr_encryption_type" {
    type = string
    default = "AES256"
    description = "The encryption type to use for the created repository. Valid values are \"AES256\" or \"KMS\". Defaults to \"AES256\"."
}
variable "ecr_encryption_key" {
    type = string
    default = null
    description = "The Amazon Resource Name (ARN) of the KMS key to use when \"ecr_encryption_type\" is \"KMS\". Default to the AWS managed key for ECR."
}
variable "ecr_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created image repository."
}