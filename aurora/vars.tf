variable "aurora_cluster_id" {
    type = string
    description = ""
}
variable "aurora_cluster_subnets" {
    type = list(string)
    description = "List of IDs for the subnets that the created Aurora cluster will span. The subnets should be in at least 3 availability zones."
}
variable "aurora_cluster_security_groups" {
    type = list(string)
    description = "List of IDs for the security groups that instances in the created Aurora cluster will be part of."
}
variable "aurora_monitoring" {
    type = object({ role = string,
                    interval = number })
    description = ""
}
variable "aurora_cluster_master_credentials" {
    type = object({ username = string,
                    password = string })
    default = { username = "postgres",
                password = "postgres" }
    description = ""
}

variable "aurora_cluster_engine" {
    type = object({ type = string,
                    mode = string
                    version = number })
    default = { type = "aurora-postgresql",
                mode = "serverless",
                version = -1 }
    description = ""
}
variable "aurora_cluster_maintenance" {
    type = object({ retention_period = number,
                    backup_window = string,
                    maintenance_window = string })
    default = { retention_period = 7,
                backup_window = "01:30-05:30",
                maintenance_window = "Wed:00:30-Wed:01:00" }
    description = ""
}
variable "aurora_logs" {
    type = list(string)
    default = [ "audit", "error", "general", "slowquery", "postgresql" ]
    description = ""
}
variable "aurora_autoscaling_config" {
    type = object({ auto_pause = bool,
                    min_capacity = number,
                    max_capacity = number,
                    idle_time = number,
                    timeout_action = string,
                    instance_type = string })
    default = { auto_pause = true,
                min_capacity = -1,
                max_capacity = -1,
                idle_time = 300,
                timeout_action = "ForceApplyCapacityChange",
                instance_type = "db.r4.large" }
    description = ""
}
variable "aurora_tags" {
    type = map(string)
    default = { }
    description = ""
}
variable "aurora_cluster_parameters" {
    type = map(string)
    default = { }
    description = ""
}

variable "aurora_default_versions" {
    type = object({ provisioned = number,
                    serverless = number })
    default = { provisioned = 12.6,
                serverless = 10.14 }
    description = ""
}