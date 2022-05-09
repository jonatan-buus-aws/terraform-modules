resource "aws_ecr_repository" "repository" {
	name = var.ecr_repository_name
	image_tag_mutability = var.ecr_enable_mutable_images == true ? "MUTABLE" : "IMMUTABLE"

	image_scanning_configuration {
		scan_on_push = true
	}
	encryption_configuration {
		encryption_type = var.ecr_encryption_type
		kms_key = var.ecr_encryption_key
	}
	tags = var.ecr_tags
}