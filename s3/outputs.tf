output "bucket_id" {
    value = aws_s3_bucket.bucket.id
    description = "The id of the created S3 bucket"
}
output "bucket_arn" {
    value = aws_s3_bucket.bucket.arn
    description = "The Amazon Resource Name (ARN) of the created S3 bucket. Will be of format: \"arn:aws:s3:::[BUCKET ID]\""
}
output "bucket_domain_name" {
    value = aws_s3_bucket.bucket.bucket_domain_name
    description = "The domain name of the created S3 bucket. Will be of format: \"[BUCKET ID].s3.amazonaws.com\""
}
output "bucket_regional_domain_name" {
    value = aws_s3_bucket.bucket.bucket_regional_domain_name
    description = "The region-specific domain name of the S3 bucket. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL"
}
output "bucket_standard_policies" {
    value = local.standard_policies
    description = "The list of generated standard policies: \"read_only\", \"read_write\", \"cloudfront\" in JSON format for the created S3 bucket"
}