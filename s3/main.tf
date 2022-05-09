# See: https://github.com/chgangaraju/terraform-aws-cloudfront-s3-website/blob/master/main.tf
locals {
	standard_policies = merge({
        "read_only" = data.aws_iam_policy_document.read_only.json,
        "read_write" = data.aws_iam_policy_document.read_write.json,
		"load_balancer" = data.aws_iam_policy_document.load_balancer.json },
		var.bucket_create_cloudfront_policy == true ? { "cloudfront" = data.aws_iam_policy_document.cloudfront.0.json } : { } )
	bucket_policy = contains(keys(local.standard_policies), var.bucket_policy) == true ? local.standard_policies[var.bucket_policy] : var.bucket_policy
}

resource "random_id" "id" {
	prefix = "${var.bucket_name}-"
	byte_length = 8
}

resource "aws_s3_bucket" "bucket" {
	bucket = random_id.id.hex
	acl = var.bucket_acl
	tags = var.bucket_tags
	
	versioning {
		enabled = false
	}
	force_destroy = true
/*
	provisioner "local-exec" {
		command = "aws s3 rb s3://${self.id} --force"
		when = destroy
	}
*/
}

resource "aws_s3_bucket_object" "file" {
	for_each = { for file in var.bucket_files : file.file_name => file }

	bucket = aws_s3_bucket.bucket.bucket

	key = each.value.file_name
	source = each.value.file_path
	content_type = each.value.content_type
	etag = filemd5(each.value.file_path)
}

resource "aws_cloudfront_origin_access_identity" "oai" {
	count = var.bucket_create_cloudfront_policy == true ? 1 : 0

	comment = "Autogenerated OAI for bucket: ${random_id.id.hex}"
}

resource "aws_s3_bucket_policy" "policy" {
	count = length(var.bucket_policy) > 0 ? 1 : 0

	bucket = aws_s3_bucket.bucket.id
	policy = local.bucket_policy
}