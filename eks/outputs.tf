output "eks_cluster_id" {
    value = aws_eks_cluster.cluster.id
    description = "The id of the created EKS cluster"
}
output "eks_cluster_arn" {
    value = aws_eks_cluster.cluster.arn
    description = "The Amazon Resource Name (ARN) of the created EKS Cluster. Will be of format: \"arn:aws:eks:::[EKS CLUSTER ID]\""
}
output "eks_cluster_endpoint" {
    value = aws_eks_cluster.cluster.endpoint
    description = "The end-point for the created EKS cluster's Kubernetes API server"
}
output "eks_standard_policies" {
    value = { "eks_cluster" = data.aws_iam_policy_document.standard_cluster_policy.json,
              "ec2_node_group" = data.aws_iam_policy_document.standard_node_group_policy.json,
              "fargate" = data.aws_iam_policy_document.standard_fargate_policy.json }
    description = "Standard IAM policies for an EKS Cluster in JSON format"
}
output "eks_service_acccount_policy" {
    value = data.aws_iam_policy_document.standard_service_account.json
    description = "Standard IAM policies for an EKS Cluster in JSON format"
}