variable "k8s_app_docker_image" {
    type = string
    description = "The docker image from where the Kubernetes App may be deployed"
}
variable "k8s_app_name" {
    type = string
    description = "The name of the Kubernetes app that will be deployed"
}

variable "k8s_app_port" {
    type = number
    default = 8080
    description = "The port number the Kubernetes App listens on"
}
variable "k8s_liveness_probe" {
    type = string
    default = "/v1/liveness-probe"
    description = "The absolute path for the Kubernetes App's liveness probe, defaults to: \"/v1/liveness-probe\""
}
variable "k8s_app_pods" {
    type = number
    default = 3
    description = "The number of pods that will be provisioned for the deployed Kubernetes App"
}
variable "k8s_app_environment_variables" {
    type = map(string)
    default = { }
    description = "The environment variables for the Kubernetes App"
}
variable "k8s_app_depends_on" {
    type = any
    default = null
    description = "Declares the Kubernetes App module's depdendencies other modules"
}
variable "k8s_app_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the deployed Kubernetes App."
}