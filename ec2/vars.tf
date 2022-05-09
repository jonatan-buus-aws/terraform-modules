variable "ec2_instances" {
    type = list(object({ subnet = string,
                         availability_zone = string }) )
    description = "List of EC2 instances to create defining the subnet and availability zone for each created instance"
}
variable "ec2_ebs_volume" {
    type = object({ size = number,
                    type = string,
                    mount_point = string })
    default = { size = 40,
                type = "gp3",
                mount_point = "/dev/sdf" }
    description = "The EBS volume that will be created for each instance and automatically attached"
}
variable "ec2_ssh_key" {
    type = object({ name = string,
                    public_key = string
                    create = bool })
    default = { name = "",
                public_key = null,
                create = false }
    description = "The SSH key that will be associated with each created instance"
}
variable "ec2_ami" {
    type = string
    default = ""
    description = "The name of the AMI that will be used to create each EC2 instance. Defaults to \"Ubuntu\""
}
variable "ec2_instance_type" {
    type = string
    default = "t3.micro"
    description = "The type of EC2 instance that will be created. Defaults to \"t3.micro\"s"
}
variable "ec2_security_groups" {
    type = list(string)
    default = [ ]
    description = "List of security groups that each created instance will be placed in"
}
variable "ec2_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created EC2 instances."
}
variable "ec2_key" {
    type = string
    default = ""
    description = ""
}
variable "ec2_iam_user" {
    type = string
    default = ""
    description = ""
}
variable "ec2_use_enhanced_monitoring" {
    type = bool
    default = true
    description = "Flag specifying whether enhanced monitoring is enabled for the created EC2 instances. Defaults to \"true\""
}
variable "ec2_allow_termination" {
    type = bool
    default = true
    description = "Flag specifying whether the created EC2 instances may be terminated by Terraform (or another API invoker). Defaults to \"true\""
}
variable "ec2_use_nitro_enclave" {
    type = bool
    default = null
    description = "Flag specifying whether the created EC2 instances will use Nitro Enclaves for enhanced security. Defaults to \"null\" which will use of Nitro Enclaves if supported by the specified instance type"
}
variable "ec2_create_elastic_ip" {
    type = bool
    default = false
    description = "Flag specifying whether to create an Elastic IP for each EC2 instance. Defaults to \"false\""
}
variable "ec2_target_group_arn" {
    type = string
    default = ""
    description = "The target group to place the created EC2 instance in"
}
variable "ec2_user_data" {
    type = string
    default = "default"
    description = "The user data to apply to each created EC2 instance. Defaults to \"default\""
}