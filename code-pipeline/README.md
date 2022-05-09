# Code Pipeline

Please see the following links for details:
- [CI/CD with Amazon EKS using AWS App Mesh and Gitlab CI](https://aws.amazon.com/blogs/containers/ci-cd-with-amazon-eks-using-aws-app-mesh-and-gitlab-ci/ "AWS documentation")
- [Build a Continuous Delivery Pipeline for Your Container Images with Amazon ECR as Source](https://aws.amazon.com/blogs/devops/build-a-continuous-delivery-pipeline-for-your-container-images-with-amazon-ecr-as-source/ "AWS documentation")
- [Create IAM Policies](https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy "Terraform documentation")
- [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket "Terraform documentation")

## Input
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| bucket\_name | The name of the S3 bucket that will be created | `String` | `none` | Yes |


### bucket_files
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| bucket\_name | The name of the S3 bucket that will be created | `String` | `none` | Yes |

## Output
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| bucket\_id | The id of the created S3 bucket | `String` |
