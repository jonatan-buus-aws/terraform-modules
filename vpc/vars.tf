variable "vpc_name" {
    type = string
    description = "The name of the created VPC"
}
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "The CIDR block for the created VPC. Defaults to \"10.0.0.0/16\""
}
variable "vpc_public_subnet_template" {
    type = string
    default = "10.0.1x.0/24"
    description = "Template for the public subnet's CIDR block in the created VPC. Defaults to \"10.0.1x.0/24\" where x will be replaced dynamically for each availability zone"
}
variable "vpc_private_subnet_template" {
    type = string
    default = "10.0.2x.0/24"
    description = "Template for the private subnet's CIDR block in the created VPC. Defaults to \"10.0.2x.0/24\" where x will be replaced dynamically for each availability zone"
}
variable "vpc_eks_subnet_template" {
    type = string
    default = "10.0.3x.0/28"
    description = "Template for the CIDR block in the private subnets intended for an EKS Cluster in the created VPC. Defaults to \"10.0.3x.0/28\" where x will be replaced dynamically for each availability zone"
}
variable "vpc_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created VPC."
}
variable "vpc_use_dns_support" {
    type = bool
    default = true
    description = "Flag specifying whether to enable DNS support for the created VPC. Defaults to \"true\""
}
variable "vpc_use_dns_hostnames" {
    type = bool
    default = true
    description = "Flag specifying whether to enable DNS hostnames for the created VPC. Defaults to \"true\""
}
variable "vpc_domain_name" {
    type = string
    default = ""
    description = "The Domain Name that will be associated with the created VPC. Defaults to \"[REGION].compute.internal\"."
}
variable "vpc_domain_name_servers" {
    type = list(string)
    default = [ "AmazonProvidedDNS" ]
    description = "List of Domain Name Servers that will be associated with the created VPC. Defaults to \"AmazonProvidedDNS\" to enable AWS to manage DNS."
}
variable "vpc_ingress" {
    type = list(object( { port = number,
                          priority = number,
                          cidr = string}) )
    default = [ { port = 22, priority = 101, cidr = "" },
                { port = 443, priority = 102, cidr = "" },
                { port = 80, priority = 103, cidr = "" },
                { port = 5432, priority = 104, cidr = "" },
                { port = 6432, priority = 105, cidr = "" },
                { port = 53, priority = 106, cidr = "" } ]
    description = "Map of ports to open for inbound traffic. Defaults to port \"22\" and \"443\"."
}
variable "vpc_egress" {
    type = list(object( { port = number,
                          priority = number,
                          cidr = string}) )
    default = [ { port = 22, priority = 201, cidr = "" },
                { port = 443, priority = 202, cidr = "0.0.0.0/0" },
                { port = 80, priority = 203, cidr = "0.0.0.0/0" },
                { port = 5432, priority = 204, cidr = "" },
                { port = 6432, priority = 205, cidr = "" },
                { port = 53, priority = 206, cidr = "" } ]
    description = "Map of ports to open for outbound traffic. Defaults to port \"443\"."
}
variable "vpc_default_security_group" {
    type = object( { name = string,
                     description = string} )
    default = { name = null,
                description = null }
    description = "Default security group for the created VPC."
}
variable "vpc_bastion_security_group" {
    type = object( { name = string,
                     description = string} )
    default = { name = null,
                description = null }
    description = "Bastion security group for the created VPC."
}
variable "vpc_eks_security_group" {
    type = object( { name = string,
                     description = string} )
    default = { name = null,
                description = null }
    description = "Security group for an EKS cluster in the created VPC."
}
variable "vpc_secure_default_vpc" {
    type = bool
    default = true
    description = "Flag specifying whether the default VPC that was auto-created by AWS will be secured by removing the \"allow all\" rules for the network ACL and security groups. Defaults to \"true\""
}
variable "vpc_unsupported_ec2_availability_zones" {
    type = set(string)
    default = [ "us-east-1e" ]
    description = "List of availability zones in which subnets will not be created for the VPC as the availability zone does not support all EC2 instance types"
}