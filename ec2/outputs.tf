output "ec2_standard_amis" {
    value = { "ubuntu" = data.aws_ami.ubuntu.id }
    description = "List of IDs for standard EC2 AMIs: \"ubuntu\""
}
output "ec2_instances" {
    value = { for k, v in aws_instance.instance : v.id => { id = v.id,
                                                            arn = v.arn,
                                                            ebs = aws_ebs_volume.volume[k].id,
                                                            subnet = v.subnet_id,
                                                            availability_zone = v.availability_zone,
                                                            private_ip = v.private_ip,
                                                            private_dns = v.private_dns,
                                                            public_ip = var.ec2_create_elastic_ip == true ? aws_eip.ip[k].public_ip : "",
                                                            public_dns = v.public_dns } }
    description = "List of the created EC2 instances"
}

output "ec2_ssh_key" {
    value = var.ec2_ssh_key.create == true && length(var.ec2_ssh_key.name) > 0 ? { id = aws_key_pair.ssh_key.0.key_pair_id,
                                                                                   arn = aws_key_pair.ssh_key.0.arn } : null
    description = "The created SSH key that may be used to access the provisioned EC2 instances" 
}