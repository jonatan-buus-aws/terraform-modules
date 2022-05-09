terraform {
  required_providers {
		kubernetes = {
			source  = "hashicorp/kubernetes"
#			version = "~> 2.3"
		}
/*
		kustomization = {
			source = "kbst/kustomization"
			version = "0.5.0"
		}
*/
	}
}

provider "kubernetes" {
    host = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
        api_version = "client.authentication.k8s.io/v1alpha1"
        command     = "aws"
        args = [
            "eks",
            "get-token",
            "--cluster-name",
            aws_eks_cluster.cluster.name
        ]
    }
}
/*
provider "kubernetes-alpha" {
	config_path = "~/.kube/config"
}

provider "kustomization" {    
	kubeconfig_path = "~/.kube/config"
}
*/