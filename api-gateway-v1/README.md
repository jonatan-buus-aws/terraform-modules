# ECR

Please see the following links for details:
- [Restricting Access to Amazon S3 Content by Using an Origin Access Identity](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html#private-content-creating-oai "AWS documentation")
- [Create IAM Policies](https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy "Terraform documentation")
- [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket "Terraform documentation")
- [Velocity Template Examples](https://stackoverflow.com/questions/40530009/serializationexception-in-posting-new-records-via-dynamodb-proxy-service-in-api "Stackoverflow")

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
