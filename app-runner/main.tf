locals {
	image_identifier = length(split(".", var.app_runner_image.identifier) ) < 2 ? "public.ecr.aws/${var.app_runner_image.identifier}" : var.app_runner_image.identifier
}

# Created IAM roles are eventually consistent, which may cause an error when creating the App Runner Service.
resource "time_sleep" "wait" {
  depends_on = [ var.app_runner_depends_on ]

  create_duration = "10s"
}

resource "aws_apprunner_service" "service" {
	depends_on = [ time_sleep.wait ]

	service_name = var.app_runner_service_name

	source_configuration {
		authentication_configuration {
    		access_role_arn = var.app_runner_image.role
    	}
		image_repository {
			image_configuration {
				port = var.app_runner_service_port
				runtime_environment_variables = var.app_runner_environment_variables
    		}
			image_identifier = local.image_identifier
			image_repository_type = can(regex("^public.ecr.aws.*$)", local.image_identifier) ) ? "ECR_PUBLIC" : "ECR"
		}
	}
	instance_configuration {
		cpu = "${var.app_runner_instance_config.cpu} vCPU"
		memory = "${var.app_runner_instance_config.memory}"
		instance_role_arn = var.app_runner_iam_role
	}
	network_configuration {
    	egress_configuration {
    		egress_type = var.app_runner_vpc_config == null ? "DEFAULT" : "VPC"
    		vpc_connector_arn = var.app_runner_vpc_config == null ? null : aws_apprunner_vpc_connector.connector.0.arn
		}
	}
	health_check_configuration {
		interval = var.app_runner_heath_check_config.interval
		timeout = var.app_runner_heath_check_config.timeout
		protocol = var.app_runner_heath_check_config.protocol
		path = var.app_runner_heath_check_config.protocol == "HTTP" ? var.app_runner_heath_check_config.path : null
		healthy_threshold = var.app_runner_heath_check_config.thresholds.healthy
		unhealthy_threshold = var.app_runner_heath_check_config.thresholds.unhealthy
	}
	tags = var.app_runner_tags
}

resource "aws_apprunner_auto_scaling_configuration_version" "config" {
	auto_scaling_configuration_name = "${var.app_runner_service_name}-config"

	max_concurrency = 50
	max_size = 10
	min_size = 2

	tags = var.app_runner_tags
}
resource "aws_apprunner_custom_domain_association" "domain" {
	for_each = var.app_runner_custom_domains

	domain_name = each.value
	service_arn = aws_apprunner_service.service.arn
}
resource "aws_apprunner_vpc_connector" "connector" {
	count = var.app_runner_vpc_config == null ? 0 : 1

	vpc_connector_name = "${var.app_runner_service_name}-connector"
	subnets = var.app_runner_vpc_config.subnets
	security_groups = var.app_runner_vpc_config.security_groups
	tags = var.app_runner_tags
}