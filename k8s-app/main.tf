locals {
	lb_name = split("-", split(".", kubernetes_service.service.status.0.load_balancer.0.ingress.0.hostname).0).0
}

resource "kubernetes_deployment" "deployment" {
	metadata {
		name = var.k8s_app_name
		labels = {
			"app" = var.k8s_app_name
		}
	}

	spec {
		revision_history_limit = 10
		strategy {
			rolling_update {
				max_unavailable = 0
			}
		}
		selector {
			match_labels = {
				"app" = var.k8s_app_name
			}
		}
		replicas = var.k8s_app_pods
		template {
			metadata {
				labels = {
					"app" = var.k8s_app_name
				}
			}
			spec {
				container {
					image = var.k8s_app_docker_image
					name = var.k8s_app_name

					dynamic "env" {
						for_each = var.k8s_app_environment_variables

						content {
							name = env.key
							value = env.value
						}
					}

					port {
						container_port = var.k8s_app_port
					}
					
					liveness_probe {
						http_get {
							path = var.k8s_liveness_probe
							port = var.k8s_app_port
						}
						period_seconds = 3
						initial_delay_seconds = 15
					}
				}
			}
		}
	}	
}
resource "kubernetes_service" "service" {
	metadata {
		name = var.k8s_app_name
		namespace = "default"
		labels = {
			"app" = var.k8s_app_name
		}
		annotations = {
			"kubernetes.io/ingress.class" = "alb"
#			"service.beta.kubernetes.io/aws-load-balancer-type" = "external"
#			"service.beta.kubernetes.io/aws-load-balancer-internal" = "0.0.0.0/0"
		}
	}
	spec {
		selector = {
			app = kubernetes_deployment.deployment.metadata.0.name
		}
		session_affinity = "None"
		port {
			port = var.k8s_app_port
			target_port = var.k8s_app_port
		}

		type = "LoadBalancer"
	}
}