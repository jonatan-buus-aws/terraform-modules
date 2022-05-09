# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
data "aws_iam_policy_document" "standard_cluster_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "eks.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "standard_node_group_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "ec2.amazonaws.com", "eks-nodegroup.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "standard_service_account" {

    statement {
        actions = [ "sts:AssumeRoleWithWebIdentity" ]
        effect  = "Allow"
        
        principals {
            type = "Federated"
            identifiers = [ aws_iam_openid_connect_provider.provider.arn ]
        }

        condition {
            test = "StringEquals"
            variable = "${replace(aws_iam_openid_connect_provider.provider.url, "https://", "")}:sub"
            values = [ "system:serviceaccount:kube-system:aws-node" ]
        }
    }
}
data "aws_iam_policy_document" "standard_fargate_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "eks-fargate-pods.amazonaws.com" ]
        }
    }
}
data "aws_iam_role" "cluster_role" {
    depends_on = [ var.eks_cluster_role ]

    name = var.eks_cluster_role
}
data "aws_iam_role" "node_role" {
    depends_on = [ var.eks_node_role ]

    name = var.eks_node_role
}
data "aws_iam_role" "fargate_role" {
    depends_on = [ var.eks_fargate_role ]

    name = var.eks_fargate_role
}
data "tls_certificate" "certificate" {
    url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}
/*
data "kubernetes_service_account" "service_account" {
	depends_on = [ aws_eks_cluster.cluster, var.eks_service_account_role ]
    
    metadata {
        name = "aws-node"
        namespace = "kube-system"
    }
}
*/
data "aws_caller_identity" "account" { }
data "aws_partition" "partition" { }
data "aws_region" "region" { }