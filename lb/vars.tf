variable "lb_name" {
    type = string
    description = "The name of the Load Balancer that will be created"
}
variable "lb_subnets" {
    type = list(string)
    description = "List of subnets that the created Load Balancer will be placed in"
}
variable "lb_security_groups" {
    type = list(string)
    description = "List of security groups the created Load Balancer will be part of."
}
variable "lb_log_bucket" {
    type = string
    description = "The name of the S3 bucket which will be used by the created Load Balancer for its access logs"
}
variable "lb_vpc" {
    type = string
    description = "The VPC that the EC2 instances for the created Load Balancer's target group are in"
}

variable "lb_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created Load Balancer."
}
variable "lb_type" {
    type = string
    default = "application"
    description = "The type of load balancer that will be created: \"application\" or \"network\". Defaults to \"application\""
}
variable "lb_internal" {
    type = bool
    default = false
    description = "Flag specifying whether the created Load Balancer will be internal or public facing. Defaults to \"false\" to create a public facing load balancer"
}
variable "lb_domain_name" {
    type = string
    default = ""
    description = "The domain name used to generate the certificate for the created Load Balancer. Set to an empty string to generate a certificate using the created Load Balancer's internal AWS DNS name"
}