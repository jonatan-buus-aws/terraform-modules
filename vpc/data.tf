data "aws_vpc" "default_vpc" {
    default = true
}
data "aws_security_groups" "default_security_groups" {
    filter {
        name = "vpc-id"
        values = [ data.aws_vpc.default_vpc.id ]
    }
}
data "aws_network_acls" "default_network_acls" {
    vpc_id = data.aws_vpc.default_vpc.id
}
data "aws_availability_zones" "zones" {
}