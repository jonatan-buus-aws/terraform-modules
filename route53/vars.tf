variable "route53_zone_domain" {
    type = string
    description = "The domain name for which a new DNS zone will be created"
}

variable "route53_description" {
    type = string
    default = ""
    description = ""
}
variable "route53_vpc" {
    type = string
    default = ""
    description = "VPC ID for a private DNS zone"
}
variable "route53_dns_records" {
    type = list(object({ name = string,
                         type = string,
                         records = list(string) }) )
    default = [ ]
    description = "List of DNS records that will be added to the created DNS zone"
}
variable "route53_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created DNS zone"
}
variable "route53_depends_on" {
    type = any
    default = null
    description = "List of key / value pairs defining the tags for the created DNS zone"
}