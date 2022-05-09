data "aws_iam_policy_document" "standard_ecr_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "build.apprunner.amazonaws.com" ]
        }
    }
}
data "aws_iam_policy_document" "standard_instance_policy" {

    statement {
        actions = [ "sts:AssumeRole" ]
        
        principals {
            type = "Service"
            identifiers = [ "tasks.apprunner.amazonaws.com" ]
        }
    }
}