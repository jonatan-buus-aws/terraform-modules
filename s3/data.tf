data "aws_iam_policy_document" "read_only" {
    statement {
        actions = ["s3:ListBucket"]
        resources = ["${aws_s3_bucket.bucket.arn}"]
        effect = "Allow"
    }
    statement {
        actions = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.bucket.arn}/*"]
        effect = "Allow"
    }
}
data "aws_iam_policy_document" "read_write" {
    statement {
        actions = ["s3:ListBucket"]
        resources = ["${aws_s3_bucket.bucket.arn}"]
        effect = "Allow"
    }
    statement {
        actions = [
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:PutObject"
        ]
        resources = ["${aws_s3_bucket.bucket.arn}/*"]
        effect = "Allow"
    }
}
# See: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
data "aws_iam_policy_document" "cloudfront" {
	count = var.bucket_create_cloudfront_policy == true ? 1 : 0

    statement {
        actions = [ "s3:GetObject" ]
        resources = ["${aws_s3_bucket.bucket.arn}/*"]
        
        principals {
            type = "AWS"
            identifiers = [ aws_cloudfront_origin_access_identity.oai.0.iam_arn ]
        }
    }
}

data "aws_elb_service_account" "load_balancer" {

}
data "aws_iam_policy_document" "load_balancer" {
    
    statement {
        actions = [ "s3:PutObject" ]
        resources = ["${aws_s3_bucket.bucket.arn}/*"]
        effect = "Allow"
        principals {
            type = "AWS"
            identifiers = [ data.aws_elb_service_account.load_balancer.arn ]
        }
    }
}