variable "apigw_api_name" {
    type = string
    description = "The name of the API which will be deployed to the API Gateway"
}
variable "apigw_role" {
    type = string
    description = "The IAM role the API Gateway will use to invoke the provied URIs"
}
variable "apigw_stage_name" {
    type = string
    description = "The name of the stage which will be deployed to the API Gateway"
}
variable "apigw_uris" {
    type = object({ initalize_payment = string,
                    get_payment = string,
                    authorize_payment = string })
    description = "The URIs the API Gateway will proxy"
}

variable "apigw_domain" {
    type = string
    default = ""
    description = "The domain name the API Gateway will be exposed at"
}
variable "apigw_json_request_templates" {
    type = map(string)
    default = { }
    description = "Map of Velocity templates used to transform the requests"
}
variable "apigw_json_request_template" {
    type = string
    default = ""
    description = "Velocity templates used to transform the requests"
}