# VPC
The S3 module will create a new S3 bucket with the specified policy and upload the provided list of files to the created bucket.
Additionally the module will generate standard policies that can be applied to the bucket using Terraform's `aws_s3_bucket_policy`.
Please see the following links for details:
- [Restricting Access to Amazon S3 Content by Using an Origin Access Identity](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html#private-content-creating-oai "AWS documentation")
- [Transitioning objects using Amazon S3 Lifecycle](https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html#lifecycle-general-considerations-transition-sc "AWS documentation")
- [Access control list (ACL) overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#sample-acl "AWS documentation")
- [Create IAM Policies](https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy "Terraform documentation")
- [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket "Terraform documentation")
- [aws_s3_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object "Terraform documentation")
- [aws_s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy "Terraform documentation")

## Input
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| bucket\_name | The name of the S3 bucket that will be created | `String` | `none` | Yes |
| bucket\_acl | The canned ACL defined by AWS for the created S3 bucket | `String` | `private` | No |
| bucket\_policy | The bucket policy in JSON format for the created S3 bucket | `JSON` | `none` | No |
| bucket\_tags | List of key / value pairs defining the tags for the created S3 bucket | `Map` | `empty list` | No |
| bucket\_files | List of files that will be uploaded to the created S3 bucket. Please see below for the format. | `Set` | `empty list` | No |
| bucket\_create\_cloudfront\_policy | Flag indicating whether a Cloudfront policy should be created. Please note that this will result in the creation of a Cloudfront OAI.
 | `Boolean` | `true` | No |

### bucket_files
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| file\_name | The name of the uploaded file in the S3 bucket | `String` |
| file\_path | The absolute or relative path to the local file that will be uploaded | `String` |
| content\_type | The content type of the uploaded file, i.e. `image/png` | `String` |

## Output
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| bucket\_id | The id of the created S3 bucket | `String` |
| bucket\_arn | The Amazon Resource Name (ARN) of the created S3 bucket. Will be of format: `arn:aws:s3:::[BUCKET ID]` | `String` |
| bucket\_domain\_name | The domain name of the created S3 bucket. Will be of format: `[BUCKET ID].s3.amazonaws.com` | `String` |
| bucket\_regional\_domain\_name | The region-specific domain name of the S3 bucket. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL | `String` |
| bucket\_standard\_policies | The list of generated standard policies: `read_only`, `read_write`, `cloudfront` in JSON format for the created S3 bucket | `Map` |
