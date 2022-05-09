output "os" {
    value = length(regexall("[a-z]:/", lower(path.cwd) ) ) > 0 ? "windows" : "linux"
    description = "The name of the operating system, either \"linux\" or \"windows\""
}
/*
output "supported_availability_zones" {
    value = keys(local.common_supported_availability_zones)
    description = "The list of supported availability zones for the specified EC2 instance type"
}
*/