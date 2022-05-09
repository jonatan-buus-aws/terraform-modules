locals {
	ec2_ami = var.ec2_ami == "" ? data.aws_ami.ubuntu.id : var.ec2_ami
	ec2_use_nitro_enclave = substr(var.ec2_instance_type, 0, 1) == "a" || substr(var.ec2_instance_type, 0, 2) == "t2" || substr(var.ec2_instance_type, 2, 1) == "g" || substr(var.ec2_instance_type, -4, -1) == "nano" || substr(var.ec2_instance_type, -5, -1) == "micro" ? false : true

	ec2_canned_templates = [ "default", "webserver", "bastion" ]
	ec2_user_data = contains(local.ec2_canned_templates, var.ec2_user_data) == true ? data.template_file.template[var.ec2_user_data].rendered : var.ec2_user_data
}

# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# See: https://www.infrastructurecode.io/resources/guest-post-beginner-s-guide-to-terraform-aws-compute-part-2
resource "aws_instance" "instance" {
	count = length(var.ec2_instances)

	ami = local.ec2_ami
	instance_type = var.ec2_instance_type

	availability_zone = var.ec2_instances[count.index].availability_zone
	subnet_id = var.ec2_instances[count.index].subnet

	tags = var.ec2_tags

	monitoring = var.ec2_use_enhanced_monitoring
	disable_api_termination = var.ec2_allow_termination == true ? false : true

	vpc_security_group_ids = var.ec2_security_groups
	key_name = var.ec2_ssh_key.name == "" ? null : var.ec2_ssh_key.name
	iam_instance_profile = var.ec2_iam_user == "" ? null : var.ec2_iam_user
	enclave_options {
		enabled = var.ec2_use_nitro_enclave == null ? local.ec2_use_nitro_enclave : var.ec2_use_nitro_enclave
	}
	user_data = local.ec2_user_data == "" ? null : local.ec2_user_data
}
resource "aws_ebs_encryption_by_default" "encryption" {
	count = var.ec2_key == "" ? 0 : 1

	enabled = true
}
resource "aws_ebs_default_kms_key" "key" {
	count = var.ec2_key == "" ? 0 : 1

	key_arn = var.ec2_key
}
resource "aws_key_pair" "ssh_key" {
	count = var.ec2_ssh_key.create == true && length(var.ec2_ssh_key.name) > 0 ? 1 : 0

	key_name = var.ec2_ssh_key.name
	public_key = var.ec2_ssh_key.public_key
}
resource "aws_ebs_volume" "volume" {
	count = length(var.ec2_instances)

	availability_zone = var.ec2_instances[count.index].availability_zone
	size = var.ec2_ebs_volume.size

	tags = var.ec2_tags
	encrypted = var.ec2_key == "" ? false : true
	type = var.ec2_ebs_volume.type

	kms_key_id = var.ec2_key == "" ? null : var.ec2_key
}
resource "aws_volume_attachment" "attachment" {
	count = length(var.ec2_instances)

	device_name = var.ec2_ebs_volume.mount_point
	volume_id = aws_ebs_volume.volume[count.index].id
	instance_id = aws_instance.instance[count.index].id
}

resource "aws_eip" "ip" {
    count = var.ec2_create_elastic_ip == true ? length(var.ec2_instances) : 0

	vpc = true
	tags = merge(var.ec2_tags, { "Name" = "public-EC2-${aws_instance.instance[count.index].id}" } )
}
resource "aws_eip_association" "eip_assoc" {
    count = var.ec2_create_elastic_ip == true ? length(var.ec2_instances) : 0

	instance_id = aws_instance.instance[count.index].id
	allocation_id = aws_eip.ip[count.index].id
}
resource "aws_lb_target_group_attachment" "attachment" {
    count = var.ec2_create_elastic_ip == true ? 0 : length(var.ec2_instances)

	target_group_arn = var.ec2_target_group_arn
	target_id = aws_instance.instance[count.index].id
	port = 80
}