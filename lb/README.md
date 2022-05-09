# Load Balancer
The Load Balancer module will create a new Application Load Balancer (ALB), which receives HTTPS requests on port 443 using an SSL certificate and forwards requests to a target group using HTTP on port 80.
An existing SSL certificate located in Amazon Certificate Manager (ACM) may be provided otherwise the module will auto-generate a new SSL certificate for the provided domain.
Please see the following links for details:
- [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb "Terraform documentation")
- [aws_lb\_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb\_target_group "Terraform documentation")
- [aws_lb\_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb\_listener "Terraform documentation")
- [aws_acm_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate "Terraform documentation")
- [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key "Terraform documentation")
- [tls_self_signed_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert "Terraform documentation")

## Input
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| lb\_name | The name of the Load Balancer that will be created | `String` | `none` | Yes |
| lb\_subnets | List of subnets that the created Load Balancer will be placed in | `List` | `none` | Yes |
| lb\_security\_groups | List of security groups the created Load Balancer will be part of | `List` | `none` | Yes |
| lb\_log\_bucket | The name of the S3 bucket which will be used by the created Load Balancer for its access logs | `String` | `none` | Yes |
| lb\_vpc | The VPC that the EC2 instances for the created Load Balancer's target group are in | `String` | `none` | Yes |
| lb\_tags | List of key / value pairs defining the tags for the created Load Balancer. | `Map` | `empty list` | No |
| lb\_type | The type of load balancer that will be created: `application` or `network`. | `String` | `application` | No |
| lb\_internal | Flag specifying whether the created Load Balancer will be internal or public facing. | `Boolean` | `false` | No |
| lb\_domain\_name | The domain name used to generate the certificate for the created Load Balancer. Set to an empty string to generate a certificate using the created Load Balancer's internal AWS DNS name | `String` | `empty string` | No |

## Output
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| lb\_target_group_arn | The ARN for the target group for the created Load Balancer. Will be of format: `arn:aws:lb:::[LOAD BALANCER ID]` | `String` |
| lb\_domain_name | The domain name for the created Load Balancer | `String` |
