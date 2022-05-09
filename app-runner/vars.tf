variable "app_runner_service_name" {
    type = string
    description = "The name of the App Runner Service that will be created."
}
variable "app_runner_image" {
    type = object({ identifier = string,
                    role = string })
    description = "The container image that will be provisioned for the created App Runner service."
}

variable "app_runner_iam_role" {
    type = string
    default = null
    description = "The ARN of the IAM role under which the created App Runner Service will run"
}
variable "app_runner_service_port" {
    type = number
    default = 8080
    description = "The port of the application for the created App Runner Service listens on. Defaults to App Runner's standard port: 8080"
}
variable "app_runner_environment_variables" {
    type = map(string)
    default = { }
    description = "A map of key/value pairs for setting the environment variables available to created running App Runner service. Keys with a prefix of AWSAPPRUNNER are reserved for system use and aren't valid."
}
variable "app_runner_auto_scaling_config" {
    type = object({ max_concurrency = number,
                    min_size = number
                    max_size = number })
    default = { max_concurrency = 50,
                  min_size = 1
                  max_size = 10 }
    description = "The auto scaling configuration for the created App Runner Service."
}
variable "app_runner_vpc_config" {
    type = object({ subnets = list(string),
                    security_groups = list(string) })
    default = null
    description = "The VPC configuration for the created App Runner Service. Defaults to NULL, which creates the App Runner Service outside any VPCs."
}
variable "app_runner_heath_check_config" {
    type = object({ interval = number,
                    timeout = number,
                    path = string,
                    protocol = string,
                    thresholds = object({ healthy = number,
                                          unhealthy = number })
                    })
    default = { interval = 5,
                timeout = 2,
                path = "/v1/liveness-probe",
                protocol = "HTTP",
                thresholds = { healthy = 1,
                               unhealthy = 5 } }
    description = "The health check configuration for the created App Runner Service. Defaults to sending a health check via HTTP to: /v1/liveness-probe every 2 seconds."
}
variable "app_runner_instance_config" {
    type = object({ cpu = number,
                    memory = number })
    default = { cpu = 1,
                memory = 2048 }
    description = "The configuration for the resources assigned to the created App Runner Service. Defaults to 1 vCPU and 2048MB memory."
}
variable "app_runner_custom_domains" {
    type = set(string)
    default = [ ]
    description = "List of custom domains that will be mapped to the created App Runner Service."
}
variable "app_runner_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created App Runner Services."
}

variable "app_runner_depends_on" {
    type = any
    default = null
    description = "Declares the App Runner module's dependencies on other modules"
}
