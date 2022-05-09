# See: https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/main.tf
locals {
	vpc_tags = merge( { "VPC" = var.vpc_name }, var.vpc_tags)
	vpc_default_security_group_name = var.vpc_default_security_group.name == "" || var.vpc_default_security_group.name == null ? "${var.vpc_name}-default-sg" : var.vpc_default_security_group.name
	vpc_bastion_security_group_name = var.vpc_bastion_security_group.name == "" || var.vpc_bastion_security_group.name == null ? "${var.vpc_name}-bastion-sg" : var.vpc_bastion_security_group.name
	vpc_eks_security_group_name = var.vpc_eks_security_group.name == "" || var.vpc_eks_security_group.name == null ? "${var.vpc_name}-eks-sg" : var.vpc_eks_security_group.name
	
	vpc_availability_zones = { for k, v in data.aws_availability_zones.zones.names : v => k if (contains(var.vpc_unsupported_ec2_availability_zones, v) == false) }

	vpc_ephemeral_access = [ aws_network_acl.public.id, aws_network_acl.public.id, aws_network_acl.eks.id, aws_network_acl.eks.id ]

	vpc_private_ports = [ 22, 5432, 6432 ]
}

# Remove default network ACL rules that have been auto-created by AWS for the default VPC
resource "null_resource" "destroy_default_network_acl_rules" {
	count = var.vpc_secure_default_vpc == true ? length(data.aws_network_acls.default_network_acls.ids) : 0

	provisioner "local-exec" {
		command = "aws ec2 delete-network-acl-entry --network-acl-id ${tolist(data.aws_network_acls.default_network_acls.ids)[count.index]} --ingress --rule-number 100"
		on_failure = continue
	}
	provisioner "local-exec" {
		command = "aws ec2 delete-network-acl-entry --network-acl-id ${tolist(data.aws_network_acls.default_network_acls.ids)[count.index]} --egress --rule-number 100"
		on_failure = continue
	}
}
# Remove default security group rules that have been auto-created by AWS for the default VPC
resource "null_resource" "destroy_default_security_groups_rules" {
	count = var.vpc_secure_default_vpc == true ? length(data.aws_security_groups.default_security_groups.ids) : 0

	provisioner "local-exec" {
		command = "aws ec2 revoke-security-group-ingress --group-id ${tolist(data.aws_security_groups.default_security_groups.ids)[count.index]} --protocol=all"
		on_failure = continue
	}
	provisioner "local-exec" {
		command = "aws ec2 revoke-security-group-egress --group-id ${tolist(data.aws_security_groups.default_security_groups.ids)[count.index]} --protocol=all"
		on_failure = continue
	}
}
# Add "deny all" network ACL rule for inbound traffic to lock down the default VPC that has been auto-created by AWS
resource "aws_network_acl_rule" "default_ingress" {
	count = var.vpc_secure_default_vpc == true ? length(data.aws_network_acls.default_network_acls.ids) : 0

    network_acl_id = tolist(data.aws_network_acls.default_network_acls.ids)[count.index]
    rule_number = 1
    egress = false
    protocol = "all"
    rule_action = "deny"
    cidr_block = "0.0.0.0/0"
}
# Add "deny all" network ACL rule for outbound traffic to lock down the default VPC that has been auto-created by AWS
resource "aws_network_acl_rule" "default_egress" {
	count = var.vpc_secure_default_vpc == true ? length(data.aws_network_acls.default_network_acls.ids) : 0

    network_acl_id = tolist(data.aws_network_acls.default_network_acls.ids)[count.index]
    rule_number = 1
    egress = true
    protocol = "all"
    rule_action = "deny"
    cidr_block = "0.0.0.0/0"
}

resource "aws_vpc" "vpc" {
	cidr_block = var.vpc_cidr
	enable_dns_support = var.vpc_use_dns_support
	enable_dns_hostnames = var.vpc_use_dns_hostnames

	tags = merge( { "Name" = var.vpc_name }, var.vpc_tags)
}

resource "aws_vpc_dhcp_options" "dhcp" {
	# Default DHCP option for US-East-1 is "ec2.internal" where as for other regions it's [REGION NAME].region.compute.internal, for example, ap-northeast-1.compute.internal).
	# The default domain name is important for EKS clusters with node groups as the EC2 instance's private dns name is used by EKS as the username
	# See: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html
	domain_name = var.vpc_domain_name == "" ? data.aws_availability_zones.zones.id == "us-east-1" ? "ec2.internal" : "${data.aws_availability_zones.zones.id}.compute.internal" : var.vpc_domain_name
	domain_name_servers = var.vpc_domain_name_servers
	tags = local.vpc_tags
}
resource "aws_vpc_dhcp_options_association" "dhcp" {
  vpc_id = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp.id
}
# ========== NETWORKING START ==========
resource "aws_subnet" "public" {
	for_each = local.vpc_availability_zones
	
	vpc_id = aws_vpc.vpc.id
	cidr_block = replace(var.vpc_public_subnet_template, "x", each.value)
	availability_zone = each.key

	tags = merge(local.vpc_tags, { "Name" = "public-subnet-${each.key}" } )
}
resource "aws_subnet" "private" {
	for_each = local.vpc_availability_zones

	vpc_id = aws_vpc.vpc.id
	cidr_block = replace(var.vpc_private_subnet_template, "x", each.value)
	availability_zone = each.key

	tags = merge(local.vpc_tags, { "Name" = "private-subnet-${each.key}" } )
}
resource "aws_subnet" "eks" {
	for_each = local.vpc_availability_zones

	vpc_id = aws_vpc.vpc.id
	cidr_block = replace(var.vpc_eks_subnet_template, "x", each.value)
	availability_zone = each.key

	tags = merge(local.vpc_tags, { "Name" = "eks-private-subnet-${each.key}" } )
}
resource "aws_eip" "ip" {
	for_each = local.vpc_availability_zones

	vpc = true
	tags = merge(local.vpc_tags, { "Name" = "public-${each.key}" } )
}

resource "aws_internet_gateway" "gateway" {
	vpc_id = aws_vpc.vpc.id
	tags = merge(local.vpc_tags, { "Name" = "public-inbound" } )
}
resource "aws_nat_gateway" "gateway" {
	# To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
	depends_on = [aws_internet_gateway.gateway]

	for_each = aws_subnet.public

	allocation_id = aws_eip.ip[each.key].id
	subnet_id = each.value.id

	tags = merge(local.vpc_tags, { "Name" = "outbound-${each.key}" } )
}

resource "aws_route_table" "public" {
	for_each = aws_subnet.public

	vpc_id = aws_vpc.vpc.id
	tags = merge(local.vpc_tags, { "Name" = "public-subnet-${each.key}" } )
}
resource "aws_route" "public_ingress" {
	for_each = aws_route_table.public

	route_table_id = each.value.id

	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.gateway.id
}
resource "aws_route_table_association" "public" {
	for_each = aws_subnet.public

	subnet_id = each.value.id
	route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route_table" "private" {
	for_each = aws_subnet.private

	vpc_id = aws_vpc.vpc.id
	tags = merge(local.vpc_tags, { "Name" = "private-subnet-${each.key}" } )
}
resource "aws_route" "private_egress" {
	for_each = aws_nat_gateway.gateway

	route_table_id = aws_route_table.private[each.key].id

	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = each.value.id
}
resource "aws_route_table_association" "private_outbound" {
	for_each = aws_subnet.private

	subnet_id = each.value.id
	route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "eks" {
	for_each = aws_subnet.eks

	vpc_id = aws_vpc.vpc.id
	tags = merge(local.vpc_tags, { "Name" = "eks-subnet-${each.key}" } )
}
resource "aws_route" "eks_egress" {
	for_each = aws_nat_gateway.gateway

	route_table_id = aws_route_table.eks[each.key].id

	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = each.value.id
}
resource "aws_route_table_association" "eks_outbound" {
	for_each = aws_subnet.eks

	subnet_id = each.value.id
	route_table_id = aws_route_table.eks[each.key].id
}

resource "aws_network_acl" "public" {
	vpc_id = aws_vpc.vpc.id
	subnet_ids = [ for v in aws_subnet.public : v.id ]
	tags = merge(local.vpc_tags, { "Name" = "public-subnets-vpc-${var.vpc_name}" } )
}

resource "aws_network_acl_rule" "public_ingress" {
	for_each = { for k, v in var.vpc_ingress : v.priority => v }

	network_acl_id = aws_network_acl.public.id
	rule_number = each.value.priority
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	# Port 80 is only required for enabling outbound communication from private subnets
	cidr_block = each.value.cidr == "" ? each.value.port == 80 ? var.vpc_cidr : "0.0.0.0/0" : each.value.cidr
	from_port = each.value.port
	to_port = each.value.port
}
resource "aws_network_acl_rule" "public_egress" {
	for_each = { for k, v in var.vpc_egress : v.priority => v }

	network_acl_id = aws_network_acl.public.id
	rule_number = each.key
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = each.value.cidr == "" ? var.vpc_cidr : each.value.cidr
	from_port = each.value.port
	to_port = each.value.port
}
# See: https://aws.amazon.com/premiumsupport/knowledge-center/resolve-connection-sg-acl-inbound/
# See: https://acloud.guru/forums/aws-certified-solutions-architect-associate/discussion/-KUbcwo4lXefMl7janaK/network-acls-ephemeral-ports
resource "aws_network_acl_rule" "ephemeral" {
	count = length(local.vpc_ephemeral_access)

	network_acl_id = local.vpc_ephemeral_access[count.index]
	rule_number = 1000
	egress = count.index % 2 == 0 ? false : true
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 1024
	to_port = 65535
}

resource "aws_default_network_acl" "private" {
	default_network_acl_id = aws_vpc.vpc.default_network_acl_id

	subnet_ids = [ for v in aws_subnet.private : v.id ]
	tags = merge(local.vpc_tags, { "Name" = "private-subnets-vpc-${var.vpc_name}" } )

	dynamic "ingress" {
		# Kubernetes uses UDP for DNS resolution which requires ephemeral UDP traffic to be allowed
		for_each = merge({ for k, v in var.vpc_ingress : v.priority => v }, { "ephemeral-tcp" = { priority = 1000, cidr = "0.0.0.0/0", port = -1 }, "ephemeral-udp" = { priority = 1001, cidr = "0.0.0.0/0", port = -1 } })

		content {
			rule_no = ingress.value.priority
			protocol = ingress.key == "ephemeral-udp" || ingress.value.port == 53 ? "udp" : "tcp"
			action = "allow"
			cidr_block = ingress.value.cidr == "" ? var.vpc_cidr : ingress.value.cidr
			from_port = ingress.value.port == -1 ? 1024 : ingress.value.port
			to_port = ingress.value.port == -1 ? 65535 : ingress.value.port
		}
	}

	dynamic "egress" {
		# Kubernetes uses UDP for DNS resolution which requires ephemeral UDP traffic to be allowed
		for_each = merge({ for k, v in var.vpc_egress : v.priority => v }, { "ephemeral-tcp" = { priority = 1000, cidr = "0.0.0.0/0", port = -1 }, "ephemeral-udp" = { priority = 1001, cidr = "0.0.0.0/0", port = -1 } })

		content {
			rule_no = egress.value.priority
			protocol = egress.key == "ephemeral-udp" || egress.value.port == 53 ? "udp" : "tcp"
			action = "allow"
			cidr_block = egress.value.cidr == "" ? var.vpc_cidr : egress.value.cidr
			from_port = egress.value.port == -1 ? 1024 : egress.value.port
			to_port = egress.value.port == -1 ? 65535 : egress.value.port
		}
	}
}

resource "aws_network_acl" "eks" {
	vpc_id = aws_vpc.vpc.id

	subnet_ids = [ for v in aws_subnet.eks : v.id ]
	tags = merge(local.vpc_tags, { "Name" = "eks-private-subnets-vpc-${var.vpc_name}" } )
}

resource "aws_network_acl_rule" "eks_ingress" {
	for_each = { for k, v in var.vpc_ingress : v.priority => v }

	network_acl_id = aws_network_acl.eks.id
	rule_number = each.value.priority
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = each.value.cidr == "" ? var.vpc_cidr : each.value.cidr
	from_port = each.value.port
	to_port = each.value.port
}
resource "aws_network_acl_rule" "eks_egress" {
	for_each = { for k, v in var.vpc_egress : v.priority => v }

	network_acl_id = aws_network_acl.eks.id
	rule_number = each.key
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = each.value.cidr == "" ? var.vpc_cidr : each.value.cidr
	from_port = each.value.port
	to_port = each.value.port
}
resource "aws_network_acl_rule" "eks_ephemeral_egress" {
	network_acl_id = aws_network_acl.eks.id
	rule_number = 1000
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 1024
	to_port = 65535
}
# ========== NETWORKING END ==========

# ========== SECURITY GROUPS START ==========
resource "aws_security_group" "default_group" {
	vpc_id = aws_vpc.vpc.id
	name_prefix = local.vpc_default_security_group_name
	description = var.vpc_default_security_group.description == "" ? "Default security group for VPC: ${var.vpc_name}" : var.vpc_default_security_group.description
	
	tags = merge(local.vpc_tags, { "Name" = "default" } )
	revoke_rules_on_delete = true
}
resource "aws_security_group_rule" "default_egress" {
	for_each = { for k, v in var.vpc_egress : v.priority => v }

	security_group_id = aws_security_group.default_group.id
	description = "Allow outbound traffic on port: ${each.value.port} in VPC: ${var.vpc_name}"
	type = "egress"
	from_port = each.value.port
	to_port = each.value.port
	protocol = "tcp"
	cidr_blocks = contains(local.vpc_private_ports, each.value.port) == true && each.value.cidr == "" ? null : [ each.value.cidr == "" ? var.vpc_cidr : each.value.cidr ]
	source_security_group_id = contains(local.vpc_private_ports, each.value.port) == true && each.value.cidr == "" ? aws_security_group.default_group.id : null
}
resource "aws_security_group_rule" "default_ingress" {
	for_each = { for k, v in var.vpc_ingress : v.priority => v if (v.port != 22) }

	security_group_id = aws_security_group.default_group.id
	description = "Allow inbound traffic on port: ${each.value.port} in VPC: ${var.vpc_name}"
	type = "ingress"
	from_port = each.value.port
	to_port = each.value.port
	protocol = "tcp"
	# Port 80 is only required for enabling outbound communication from private subnets
	cidr_blocks = [ each.value.port == 80 && each.value.cidr == "" ? var.vpc_cidr : "0.0.0.0/0" ]
}

resource "aws_security_group" "bastion_group" {
	vpc_id = aws_vpc.vpc.id
	name_prefix = local.vpc_bastion_security_group_name
	description = var.vpc_bastion_security_group.description == "" ? "Bastion security group for VPC: ${var.vpc_name}" : var.vpc_bastion_security_group.description
	
	tags = merge(local.vpc_tags, { "Name" = "bastion" } )
	revoke_rules_on_delete = true
}
resource "aws_security_group_rule" "bastion_egress" {
	for_each = { for k, v in var.vpc_egress : v.priority => v }

	security_group_id = aws_security_group.bastion_group.id
	description = "Allow outbound traffic on port: ${each.value.port} in VPC: ${var.vpc_name}"
	type = "egress"
	from_port = each.value.port
	to_port = each.value.port
	protocol = "tcp"
	cidr_blocks = contains(local.vpc_private_ports, each.value.port) == true && each.value.cidr == "" ? null : [ each.value.cidr == "" ? var.vpc_cidr : each.value.cidr ]
	source_security_group_id = contains(local.vpc_private_ports, each.value.port) == true && each.value.cidr == "" ? aws_security_group.default_group.id : null
}
resource "aws_security_group_rule" "bastion_ingress" {
	security_group_id = aws_security_group.bastion_group.id
	description = "Allow inbound SSH traffic on port: 22 in VPC: ${var.vpc_name}"
	type = "ingress"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = [ "0.0.0.0/0" ]
}
resource "aws_security_group_rule" "default_ssh_ingress" {
	security_group_id = aws_security_group.default_group.id
	description = "Allow inbound SSH traffic on port: 22 in VPC: ${var.vpc_name}"
	type = "ingress"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	source_security_group_id = aws_security_group.bastion_group.id
}
# ========== SECURITY GROUPS END ==========