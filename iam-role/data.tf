data "aws_iam_policy_document" "eks_cluster_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "eks.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "eks_node_group_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "ec2.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "cloudwatch_policy" {

    statement {
        actions = [
                "logs:CreateLogDelivery",
                "logs:GetLogDelivery",
                "logs:UpdateLogDelivery",
                "logs:DeleteLogDelivery",
                "logs:ListLogDeliveries",
                "logs:PutResourcePolicy",
                "logs:DescribeResourcePolicies",
                "logs:DescribeLogGroups"
            ]
        effect  = "Allow"

        resources = [ "*" ]
    }
}
data "aws_iam_policy_document" "api_gateway_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "apigateway.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "step_function_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "states.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "eks_service_account_policy" {

    statement {
        actions = [ "sts:AssumeRoleWithWebIdentity" ]
        
        principals {
            type = "Federated"
            identifiers = [ "$${OIDC_ARN}" ]
        }
        
        condition {
            test = "StringEquals"
            variable = "$${OIDC_URL}:sub"
            values = [ "system:serviceaccount:$${NAMESPACE}:$${SA_NAME}" ]
        }
    }
}