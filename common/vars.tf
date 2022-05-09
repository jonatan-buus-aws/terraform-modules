variable "common_instance_type" {
    type = string
    default = "t3.micro"
    description = "The type of EC2 instance that will be used to determine the supported availability zones. Defaults to \"t3.micro\"s"
}
variable "common_temp_path" {
    type = string
    default = ""
    description = "The absolute path to a temporary directory where Terraform may write files. Defaults to current working directory."
}