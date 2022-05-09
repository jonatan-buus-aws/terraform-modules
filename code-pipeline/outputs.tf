output "ecr_repository_id" {
    value = aws_ecr_repository.repository.registry_id
    description = "The registry ID where the repository was created."
}
output "ecr_repository_arn" {
    value = aws_ecr_repository.repository.arn
    description = "The full Amazon Resource Name (ARN) of the created repository."
}
output "ecr_repository_url" {
    value = aws_ecr_repository.repository.repository_url
    description = "The URL of the created repository in the format: \"aws_account_id.dkr.ecr.region.amazonaws.com/[ECR REPOSITORY NAME]\"."
}