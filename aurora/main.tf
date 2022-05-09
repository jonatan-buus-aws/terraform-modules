locals {
	cluster_availability_zones = { for v in data.aws_subnet.subnet : v.availability_zone_id => v.availability_zone  }
	engine_version = var.aurora_cluster_engine.version == -1 ? var.aurora_default_versions[var.aurora_cluster_engine.mode] : var.aurora_cluster_engine.version
	cluster_parameter_group = lookup(var.aurora_cluster_parameters, "name", "") == "" ? "${var.aurora_cluster_id}-parameters" : var.aurora_cluster_parameters.name
}

resource "aws_rds_cluster" "cluster" {
	cluster_identifier = var.aurora_cluster_id
	engine = var.aurora_cluster_engine.type
	engine_mode = var.aurora_cluster_engine.mode
	engine_version = local.engine_version
	db_subnet_group_name = aws_db_subnet_group.group.name
	availability_zones = values(local.cluster_availability_zones)
	master_username = var.aurora_cluster_master_credentials.username
	master_password = var.aurora_cluster_master_credentials.password
	backup_retention_period = var.aurora_cluster_maintenance.retention_period
	preferred_backup_window = var.aurora_cluster_maintenance.backup_window
	preferred_maintenance_window = var.aurora_cluster_maintenance.maintenance_window
	vpc_security_group_ids = var.aurora_cluster_security_groups
	db_cluster_parameter_group_name = length(var.aurora_cluster_parameters) == 0 ? null : aws_db_parameter_group.parameters.0.name

	tags = var.aurora_tags
	enable_http_endpoint = var.aurora_cluster_engine.mode == "serverless" ? true : false
	enabled_cloudwatch_logs_exports = var.aurora_cluster_engine.mode == "serverless" ? [ ] : var.aurora_logs

	copy_tags_to_snapshot = true
	iam_database_authentication_enabled = var.aurora_cluster_engine.mode == "serverless" ? false : true

	dynamic "scaling_configuration" {
		for_each = var.aurora_cluster_engine.mode == "serverless" ? toset([ var.aurora_autoscaling_config ]) : [ ]

		content {
			auto_pause = scaling_configuration.value.auto_pause
			min_capacity = scaling_configuration.value.min_capacity == -1 ? 2 : scaling_configuration.value.min_capacity
			max_capacity = scaling_configuration.value.max_capacity == -1 ? 16 : scaling_configuration.value.max_capacity
			seconds_until_auto_pause = scaling_configuration.value.idle_time
			timeout_action = scaling_configuration.value.timeout_action
		}
  	}

	skip_final_snapshot  = true
	final_snapshot_identifier = "${var.aurora_cluster_id}-final-snapshot"
}

resource "aws_db_subnet_group" "group" {
	name = "subnets-for-${var.aurora_cluster_id}"
	subnet_ids = var.aurora_cluster_subnets

	tags = {
		name = "Subnets for Aurora Cluster: ${var.aurora_cluster_id}"
	}
}

resource "aws_rds_cluster_instance" "cluster_instances" {
	count = var.aurora_cluster_engine.mode == "serverless" ? 0 : var.aurora_autoscaling_config.min_capacity

	identifier = "${aws_rds_cluster.cluster.id}-instance-${count.index}"
	cluster_identifier = aws_rds_cluster.cluster.id
	instance_class = var.aurora_autoscaling_config.instance_type
	engine = aws_rds_cluster.cluster.engine
	engine_version = aws_rds_cluster.cluster.engine_version

	db_subnet_group_name = aws_db_subnet_group.group.name
	availability_zone = local.cluster_availability_zones[count.index % length(local.cluster_availability_zones)]

	monitoring_role_arn = data.aws_iam_role.monitoring_role.arn
	monitoring_interval = var.aurora_monitoring.interval

	publicly_accessible = false
	performance_insights_enabled = true
	copy_tags_to_snapshot = aws_rds_cluster.cluster.copy_tags_to_snapshot
	preferred_backup_window = aws_rds_cluster.cluster.preferred_backup_window
	preferred_maintenance_window = aws_rds_cluster.cluster.preferred_maintenance_window

	tags = aws_rds_cluster.cluster.tags

	lifecycle {
		ignore_changes = [ engine_version ]
	}
}

resource "aws_rds_cluster_endpoint" "reads" {
	count = var.aurora_cluster_engine.mode == "serverless" ? 0 : 1

	cluster_identifier = aws_rds_cluster.cluster.id
	cluster_endpoint_identifier = "reads"
	custom_endpoint_type = "READER"

	excluded_members = [ ]
}
resource "aws_rds_cluster_endpoint" "writes" {
	count = var.aurora_cluster_engine.mode == "serverless" ? 0 : 1
	
	cluster_identifier = aws_rds_cluster.cluster.id
	cluster_endpoint_identifier = "writes"
	custom_endpoint_type = "ANY"

	excluded_members = [ ]
}

resource "aws_db_parameter_group" "parameters" {
	count = length(var.aurora_cluster_parameters)

	name = local.cluster_parameter_group
	description = lookup(var.aurora_cluster_parameters, "description", "Parameters for ${local.cluster_parameter_group}")
	family = "${replace(var.aurora_cluster_engine.type, "aurora-postgresql", "postgres")}${floor(local.engine_version)}"

	dynamic "parameter" {
		for_each = { for k, v in var.aurora_cluster_parameters : k => v if (k != "name" && k != "description") }

		content {
			name  = parameter.key
			value = parameter.value
		}
	}
	tags = var.aurora_tags
}