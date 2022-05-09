module "common" {
	source = "../common"
}

# See: https://github.com/terraform-aws-modules/terraform-aws-eks
locals {
	control_plane_ports = var.eks_secure_cluster == true ? { "https" = 443, "kubernetes-apiserver" = 10250 } : { }
	node_group_subnets = length(var.eks_node_config.subnets) == 0 ? var.eks_cluster_subnets : var.eks_node_config.subnets
	fargate_subnets = length(var.eks_fargate_config.subnets) == 0 ? var.eks_cluster_subnets : var.eks_fargate_config.subnets

	spot_group_ignore_changes = (var.eks_spot_scaling_config.max_size == -1 && var.eks_spot_scaling_config.desired_size == -1) || var.eks_spot_scaling_config.desired_size < var.eks_spot_scaling_config.max_size ? [ var.eks_spot_scaling_config.desired_size ] : [ ]

	eks_service_account_role = substr(var.eks_service_account_role, 0, 1) == "/" ? substr(var.eks_service_account_role, 1, length(var.eks_service_account_role) ) : var.eks_service_account_role
	service_account_arn = "arn:${data.aws_partition.partition.id}:iam::${data.aws_caller_identity.account.account_id}:role/${local.eks_service_account_role}"
	node_role_arn = "arn:${data.aws_partition.partition.id}:iam::${data.aws_caller_identity.account.account_id}:role/${var.eks_node_role}" 
	farget_role_arn = "arn:${data.aws_partition.partition.id}:iam::${data.aws_caller_identity.account.account_id}:role/${var.eks_fargate_role}" 

	patch_script = module.common.os == "windows" ? "patch.bat" : "patch.sh"

	node_group_auth_config = [ { groups = [ "system:bootstrappers", "system:nodes" ],
								 rolearn = local.node_role_arn,
								 username = "system:node:{{EC2PrivateDNSName}}" } ]
	fargate_auth_config = [ { groups = [ "system:bootstrappers", "system:nodes", "system:node-proxier" ],
								 rolearn = local.farget_role_arn,
								 username = "system:node:{{SessionName}}" } ]
}

resource "aws_eks_cluster" "cluster" {
	name = var.eks_cluster_name
	role_arn = data.aws_iam_role.cluster_role.arn
	version = var.eks_cluster_version

	enabled_cluster_log_types = var.eks_cluster_logs
	kubernetes_network_config {
		service_ipv4_cidr = var.eks_cluster_cidr
	}

	vpc_config {
		security_group_ids = var.eks_security_groups
		subnet_ids = var.eks_cluster_subnets
		endpoint_private_access = true
	}
	tags = var.eks_tags

	lifecycle {
		ignore_changes = [ vpc_config[0].endpoint_public_access ]
	}

	# Configures kubectl to enable connections to the created EKS cluster.
	provisioner "local-exec" {
		command = "aws eks update-kubeconfig --name ${var.eks_cluster_name} --region ${data.aws_region.region.name}"
	}
}

resource "aws_iam_openid_connect_provider" "provider" {
	client_id_list = [ "sts.amazonaws.com" ]
	thumbprint_list = [ data.tls_certificate.certificate.certificates.0.sha1_fingerprint]
	url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

# See: https://medium.com/@alex.veprik/setting-up-aws-eks-cluster-entirely-with-terraform-e90f50ab7387
resource "kubernetes_config_map" "config_map" {
	depends_on = [ aws_eks_cluster.cluster ]
	
	metadata {
		name = "aws-auth"
		namespace = "kube-system"
		labels = { "app.kubernetes.io/managed-by" = "Terraform" }
	}
	data = {
		# Remove double quotes added by yamlencode to enclose all strings, which results in an invalid the configuration map
		mapRoles = replace(yamlencode(concat(var.eks_node_role == "" ? [ ] : local.node_group_auth_config, var.eks_fargate_role == "" ? [ ] : local.fargate_auth_config) ), "\"", "")
/*
mapRoles = <<YAML
- groups
	- system:bootstrappers
	- system:nodes
	rolearn = local.node_role_arn
	username = system:node:{{EC2PrivateDNSName}}
YAML
*/
	}
/*
	# Recreate the config map exists before destroying it as EKS automatically removes it when the node groups are destroyed
	provisioner "local-exec" {
		when = destroy
		command = "kubectl create -f ${path.module}/configmap.yaml"
	}
*/
}

/*
# There's currently a bug in the Terrform Kubernete-Alpha provider which prevents it from honouring the depends_on
resource "kubernetes_manifest" "manifest" {
	depends_on = [ aws_eks_cluster.cluster ]

	provider = kubernetes-alpha

	manifest = {
		"apiVersion" = "v1"
		"kind" = "ServiceAccount"
		"metadata" = {
			"name" = "aws-node"
			"namespace" = "kube-system"
			"annotations" = {
				"eks.amazonaws.com/role-arn" = local.service_account_arn
			}
		}
	}
}
*/
# Patch the configuration for the Kubernetes service account: aws-node that's automatically created by EKS
# using "kubectl patch" so it references the provided EKS Service Account IAM role
resource "null_resource" "patch" {
	depends_on = [ aws_eks_cluster.cluster ]

	provisioner "local-exec" {
		command = "${abspath(path.module)}/${local.patch_script} ${local.service_account_arn}"
	}
}

resource "aws_eks_node_group" "on_demand" {
	depends_on = [ null_resource.patch, kubernetes_config_map.config_map ]

	count = var.eks_on_demand_scaling_config.max_size == -1 || var.eks_on_demand_scaling_config.max_size > 0 ? 1 : 0

	cluster_name = aws_eks_cluster.cluster.id
  	node_group_name = var.eks_on_demand_scaling_config.name == "" ? "${aws_eks_cluster.cluster.id}-on-demand-group" : var.eks_on_demand_scaling_config.name
	subnet_ids = local.node_group_subnets
	node_role_arn = data.aws_iam_role.node_role.arn

	capacity_type = "ON_DEMAND"
	ami_type = var.eks_node_config.ami_type
	instance_types = [ var.eks_node_config.instance_type ]
	disk_size = var.eks_node_config.disk_size
	labels = var.eks_node_config.labels
	tags = merge(var.eks_tags, { "kubernetes.io/cluster/${aws_eks_cluster.cluster.id}" = "owned" })
	
	scaling_config {
		min_size = var.eks_on_demand_scaling_config.min_size == -1 ? length(local.node_group_subnets) : var.eks_on_demand_scaling_config.min_size
		max_size = var.eks_on_demand_scaling_config.max_size == -1 ? length(local.node_group_subnets) : var.eks_on_demand_scaling_config.max_size
		desired_size = var.eks_on_demand_scaling_config.desired_size == -1 ? length(local.node_group_subnets) : var.eks_on_demand_scaling_config.desired_size
	}

	dynamic "launch_template" {
		for_each = var.eks_node_config.launch_template_name == "" ? { } : { var.eks_node_config.launch_template_name = var.eks_node_config.launch_template_version }
		
		content {
			name = var.eks_node_config.launch_template_name
			version = var.eks_node_config.launch_template_version
		}
	}

	dynamic "remote_access" {
		for_each = var.eks_node_ssh_key == "" ? { } : { "key" = var.eks_node_ssh_key }

		content {
			ec2_ssh_key = var.eks_node_ssh_key
			source_security_group_ids = var.eks_node_ssh_security_groups
		}
	}

	# Optional: Allow external changes without Terraform plan difference
	lifecycle {
		ignore_changes = [ scaling_config[0].desired_size ]
	}
	timeouts {
		create = "10m"
	}
}

resource "aws_eks_node_group" "spot" {
	depends_on = [ null_resource.patch, kubernetes_config_map.config_map ]
	
	count = var.eks_spot_scaling_config.max_size == -1 || var.eks_spot_scaling_config.max_size > 0 ? 1 : 0
	
	cluster_name = aws_eks_cluster.cluster.id
  	node_group_name = var.eks_spot_scaling_config.name == "" ? "${aws_eks_cluster.cluster.id}-spot-group" : var.eks_spot_scaling_config.name
	subnet_ids = local.node_group_subnets
	node_role_arn = data.aws_iam_role.node_role.arn

	capacity_type = "SPOT"
	ami_type = var.eks_node_config.ami_type
	instance_types = [ var.eks_node_config.instance_type ]
	disk_size = var.eks_node_config.disk_size
	labels = var.eks_node_config.labels
	tags = merge(var.eks_tags, { "kubernetes.io/cluster/${aws_eks_cluster.cluster.id}" = "owned" })
	
	scaling_config {
		min_size = var.eks_spot_scaling_config.min_size == -1 ? length(local.node_group_subnets) : var.eks_spot_scaling_config.min_size
		max_size = var.eks_spot_scaling_config.max_size == -1 ? length(local.node_group_subnets) * 2 : var.eks_spot_scaling_config.max_size
		desired_size = var.eks_spot_scaling_config.desired_size == -1 ? length(local.node_group_subnets) : var.eks_spot_scaling_config.desired_size
	}

	dynamic "launch_template" {
		for_each = var.eks_node_config.launch_template_name == "" ? { } : { var.eks_node_config.launch_template_name = var.eks_node_config.launch_template_version }
		
		content {
			name = var.eks_node_config.launch_template_name
			version = var.eks_node_config.launch_template_version
		}
	}

	dynamic "remote_access" {
		for_each = var.eks_node_ssh_key == "" ? { } : { "key" = var.eks_node_ssh_key }

		content {
			ec2_ssh_key = var.eks_node_ssh_key
			source_security_group_ids = var.eks_node_ssh_security_groups
		}
	}

	# Optional: Allow external changes without Terraform plan difference
	lifecycle {
		ignore_changes = [ scaling_config[0].desired_size ]
	}
	timeouts {
		create = "10m"
	}
}

resource "aws_eks_fargate_profile" "profile" {
	depends_on = [ null_resource.patch, kubernetes_config_map.config_map ]
	
	count = var.eks_fargate_config == null || var.eks_fargate_config.namespace == "" ? 0 : 1
	
	cluster_name = aws_eks_cluster.cluster.id
  	fargate_profile_name = var.eks_fargate_config.name == "" ? "${aws_eks_cluster.cluster.id}-fargate-profile" : var.eks_fargate_config.name
	subnet_ids = local.fargate_subnets
	pod_execution_role_arn = data.aws_iam_role.fargate_role.arn
	tags = var.eks_tags

	selector {
		namespace = var.eks_fargate_config.namespace
		labels = var.eks_kubernetes_labels
	}
}
resource "aws_eks_addon" "addon" {
	depends_on = [ null_resource.patch, kubernetes_config_map.config_map ]
	
	for_each = toset(var.eks_add_ons)
	
	cluster_name = aws_eks_cluster.cluster.id
	addon_name = each.value
}

# Disable public access to the EKS cluster's API Server
resource "null_resource" "cluster" {
	depends_on = [ aws_eks_node_group.on_demand, aws_eks_node_group.spot, aws_eks_fargate_profile.profile, aws_eks_addon.addon ]

	triggers = {
		region = data.aws_region.region.name
		cluster = var.eks_cluster_name
		public_access = var.eks_secure_cluster == true ? "false" : "true"
		role = data.aws_iam_role.cluster_role.arn
	}

	# Disable public access to the EKS cluster's API Server if var.eks_secure_cluster is set to true
	provisioner "local-exec" {
		command = "aws eks update-cluster-config --name ${self.triggers.cluster} --region ${self.triggers.region} --resources-vpc-config endpointPrivateAccess=true,endpointPublicAccess=${self.triggers.public_access}"
	}
/*
	# Node groups and Fargate profiles can be added to the cluster while it's updating
	# Wait for 30 seconds for the EKS cluster to start updating
	provisioner "local-exec" {
		command = "PING localhost -n 30 >NUL"
	}
	# Wait until the EKS cluster to finish updating
	provisioner "local-exec" {
		command = "aws eks wait cluster-active --name ${self.triggers.cluster} --region ${self.triggers.region}"
	}
*/
	# Renable public access to the EKS cluster's API Server so changes to the Kubernetes configuration can be reverted
/*
	provisioner "local-exec" {
		when = destroy
		command = "aws sts assume-role --role-arn arn:aws:iam::996046942922:role/my-eks-cluster --role-session-name ${self.triggers.cluster}"
	}
*/
	provisioner "local-exec" {
		when = destroy
		command = "aws eks update-cluster-config --name ${self.triggers.cluster} --region ${self.triggers.region} --resources-vpc-config endpointPrivateAccess=true,endpointPublicAccess=true"
	}
	# Wait for 30 seconds for the EKS cluster to start updating
	provisioner "local-exec" {
		when = destroy
		command = "PING localhost -n 30 >NUL"
	}
	# Wait until the EKS cluster to finish updating
	provisioner "local-exec" {
		when = destroy
		command = "aws eks wait cluster-active --name ${self.triggers.cluster} --region ${self.triggers.region}"
	}
}

# Remove default security group rules that have been auto-created by AWS for the EKS cluster's default security group
resource "null_resource" "destroy_default_security_groups_rules" {
	depends_on = [ aws_eks_cluster.cluster ]

	count = var.eks_secure_cluster == true ? 1 : 0

	provisioner "local-exec" {
		command = "aws ec2 revoke-security-group-ingress --group-id ${aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id} --protocol=all"
		on_failure = continue
	}
	provisioner "local-exec" {
		command = "aws ec2 revoke-security-group-egress --group-id ${aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id} --protocol=all"
		on_failure = continue
	}
}

resource "aws_security_group_rule" "eks_egress" {
	for_each = local.control_plane_ports

	security_group_id = aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
	description = "Allow outbound traffic for the EKS control plane on port: ${each.value} in VPC: ${aws_eks_cluster.cluster.vpc_config.0.vpc_id}"
	type = "egress"
	from_port = each.value
	to_port = each.value
	protocol = "tcp"
	source_security_group_id = aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
}
resource "aws_security_group_rule" "eks_ingress" {
	for_each = local.control_plane_ports

	security_group_id = aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
	description = "Allow inbound traffic for the EKS control plane on port: ${each.value} in VPC: ${aws_eks_cluster.cluster.vpc_config.0.vpc_id}"
	type = "ingress"
	from_port = each.value
	to_port = each.value
	protocol = "tcp"
	source_security_group_id = aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
}