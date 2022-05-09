locals {
	lb_name = split("-", split(".", kubernetes_service.service.status.0.load_balancer.0.ingress.0.hostname).0).0
}

resource "kubernetes_secret" "secret" {
	depends_on = [ var.pgbouncer_depends_on ]

	metadata {
		name = "pgbouncer-config"
		namespace = "default"
	}

	data = {
		"pgbouncer.ini" = data.template_file.pgbouncer.rendered
		"userlist.txt" = data.template_file.userlist.rendered
	}
}
resource "kubernetes_deployment" "deployment" {
	metadata {
		name = "pgbouncer"
		labels = {
			"app" = "pgbouncer"
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
				"app" = "pgbouncer"
			}
		}
		replicas = var.pgbouncer_pods
		template {
			metadata {
				labels = {
					"app" = "pgbouncer"
				}
			}
			spec {
				container {
					image = "edoburu/pgbouncer:1.9.0"
					name = "pgbouncer"

					env {
						name  = "LISTEN_PORT"
						value = var.pgbouncer_port
					}

					port {
						container_port = var.pgbouncer_port
					}
					
					liveness_probe {
						tcp_socket {
							port = var.pgbouncer_port
						}
						period_seconds = 1
					}

					volume_mount {
						name = "configfiles"
						mount_path = "/etc/pgbouncer"
						read_only = true
					}
					lifecycle {
						pre_stop {
							exec {
								command = ["/bin/sh", "-c", "killall -INT pgbouncer && sleep 120"]
							}
						}
					}
					security_context {
						allow_privilege_escalation = false
						capabilities {
							drop = [ "all" ]
						}
					}
				}
				volume {
					name = "configfiles"
					secret {
						secret_name = kubernetes_secret.secret.metadata.0.name
					}
				}
			}
		}
	}	
}
resource "kubernetes_service" "service" {
	metadata {
		name = "pgbouncer"
		namespace = "default"
		labels = {
			"app" = "pgbouncer"
		}

		annotations = {
			"service.beta.kubernetes.io/aws-load-balancer-internal" = "0.0.0.0/0"
		}
	}
	spec {
		selector = {
			app = kubernetes_deployment.deployment.metadata.0.name
		}
		session_affinity = "None"
		port {
			port = var.pgbouncer_port
			target_port = var.pgbouncer_port
		}

		type = "LoadBalancer"
	}
}