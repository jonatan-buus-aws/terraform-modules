/*
locals {
    common_temp_path = var.common_temp_path == "" ? path.cwd : var.common_temp_path

	common_supported_availability_zones = { for v in jsondecode(data.local_file.supported_availability_zones.content).ReservedInstancesOfferings : v.AvailabilityZone => v } 

}
# Retrieve information about the supported instance types for the availability zones
resource "null_resource" "supported_availability_zones" {
	provisioner "local-exec" {
		command = "aws ec2 describe-reserved-instances-offerings --filters \"Name=scope,Values=Availability Zone\" --no-include-marketplace --instance-type ${var.common_instance_type} > ${local.common_temp_path}/instance_type.json"
#		on_failure = continue
	}
}
*/