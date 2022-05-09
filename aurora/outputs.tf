output "aurora_cluster_endpoints" {
    value = { reads = var.aurora_cluster_engine.mode == "serverless" ? aws_rds_cluster.cluster.reader_endpoint : aws_rds_cluster_endpoint.reads.0.endpoint,
              writes = var.aurora_cluster_engine.mode == "serverless" ? aws_rds_cluster.cluster.endpoint : aws_rds_cluster_endpoint.writes.0.endpoint }
    description = "The end-points which may be used to access the created Aurora database cluster"
}
output "aurora_standard_policies" {
    value = { "monitoring" = data.aws_iam_policy_document.standard_monitoring_policy.json }
    description = "Standard IAM policies for an Aurora cluster in JSON format"
}