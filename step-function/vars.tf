variable "function_name" {
    type = string
    description = "The name of the state machine that will be created"
}
variable "function_role" {
    type = string
    description = "The name of the IAM role that the created state machine will use to execute the functional steps"
}
variable "function_definition" {
    type = string
    description = "The functional steps that will be executed by the created state machine"
}