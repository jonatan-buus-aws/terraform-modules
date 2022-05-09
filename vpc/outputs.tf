output "vpc_id" {
    value = aws_vpc.vpc.id
    description = "The id of the created VPC"
}
output "vpc_public_subnets" {
    value = { for v in aws_subnet.public : v.availability_zone => v.id }
    description = "Map of ids for the public subnets in each availability zone that was created for the VPC"
}
output "vpc_private_subnets" {
    value = { for v in aws_subnet.private : v.availability_zone => v.id }
    description = "Map of ids for the private subnets in each availability zone that was created for the VPC"
}
output "vpc_eks_subnets" {
    value = { for v in aws_subnet.eks : v.availability_zone => v.id }
    description = "Map of ids for the private subnets intended for an EKS Cluster in each availability zone that was created for the VPC"
}
output "vpc_elastic_ips" {
    value = { for k, v in aws_eip.ip : k => { public_ip = v.public_ip,
                                              private_ip = v.private_ip } }
    description = "The public and private IP for the elastic IPs that were created for the VPC for each availability zone"
}
output "vpc_default_security_group" {
    value = aws_security_group.default_group.id
    description = "The default security group that was created for the VPC"
}
output "vpc_bastion_security_group" {
    value = aws_security_group.bastion_group.id
    description = "The bastion security group that was created for the VPC"
}