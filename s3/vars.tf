variable "bucket_name" {
    type = string
    description = "The name of the S3 bucket that will be created."
}
# See: https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl
variable "bucket_acl" {
    type = string
    default = "private"
    description = "The canned ACL defined by AWS for the created S3 bucket. Defaults to \"private\"."
}
# See: https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html
variable "bucket_policy" {
    type = string
    default = ""
    description = "The bucket policy in JSON format for the created S3 bucket."
}
variable "bucket_tags" {
    type = map(string)
    default = { }
    description = "List of key / value pairs defining the tags for the created S3 bucket."
}
variable "bucket_files" {
    type = set(object({ file_name = string,
                        file_path = string,
                        content_type = string }) )
    default = [ ]
    description = "List of files that will be uploaded to the created S3 bucket."
}
variable "bucket_create_cloudfront_policy" {
    type = bool
    default = true
    description = "Flag indicating whether a Cloudfront policy should be created. Please note that this will result in the creation of a Cloudfront OAI."
}