data "aws_iam_policy_document" "standard_monitoring_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "monitoring.rds.amazonaws.com" ]
        }
    }
}

data "aws_subnet" "subnet" {
    depends_on = [ var.aurora_cluster_subnets ]

    for_each = toset(var.aurora_cluster_subnets)

    id = each.value
}
data "aws_iam_role" "monitoring_role" {
    depends_on = [ var.aurora_monitoring ]

    name = var.aurora_monitoring.role
}