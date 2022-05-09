# Aurora

Please see the following links for details:
- [Amazon Aurora PostgreSQL releases and engine versions](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Updates.20180305.html "AWS documentation")
- [Extension versions for Amazon Aurora PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Extensions.html "AWS documentation")
- [IAM database authentication](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.html "AWS documentation")
- [Best practices for working with Amazon Aurora Serverless](https://aws.amazon.com/blogs/database/best-practices-for-working-with-amazon-aurora-serverless/ "AWS documentation")
- [Working with PostgreSQL parameters](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Parameters "AWS documentation")
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
