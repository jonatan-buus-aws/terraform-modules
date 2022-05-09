# IAM Role
The IAM Role module will create a new IAM Role with a list of attached policies
Please see the following links for details:
- [Create IAM Policies](https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy "Terraform documentation")
- [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role "Terraform documentation")

## Input
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| iam\_role\_name | The name of the IAM role that will be created | `String` | `none` | Yes |
| iam\_assume\_role\_policy | The policy document as a JSON formatted string that grants an entity permission to assume the created role. | `String` | `none` | Yes |
| iam\_role\_description | The description of the IAM role that will be created. | `String` | `An informative listing of the provided policy names will be constructed` | No |
| iam\_role\_path | The path in which the IAM role will be created | `String` | `/roles/` | No |
| iam\_tags | List of key / value pairs defining the tags for the created IAM policies and IAM users | `Map` | `empty list` | No |
| iam\_policies | List of objects representing the policies that will be created and associated with the created IAM role. | `List` | `empty list` | No |
| iam\_policy\_attachments | List of Amazon Resource Names (ARNs) for existing policies that will be associated with the created IAM role. | `List` | `empty list` | No |

### iam_policies
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| name | The name of the created IAM policy | `String` | `none` | Yes |
| description | Description of the created IAM policy | `String` | `Policy for role: [ROLE NAME]` | No |
| path | The path in which the IAM policy will be created. See [IAM Identifiers](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html "AWS documentation") for more information. | `String` | `/roles/[ROLE NAME]/policies/` | No |
| policy | The policy document as a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the [AWS IAM Policy Document Guide](https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy "Terraform documentation") | `String` | `none` | Yes |

## Output
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| iam\_role | Object representing the created IAM role, see below for details. | `Object` |
| iam\_users | Map of objects with the username as the key representing the created IAM users, see below for details | `Map` |
| iam\_created\_policies | Map of objects with the policy name as the key representing the created IAM policies, see below for details | `Map` |
| iam\_standard\_policies | The list of generated standard IAM policies:  `eks_cluster`  `eks_node_group` and  `eks_service_account` in JSON format. These policies may be passed as input to the module through the `iam_assume_role_policy` input variable or in the `policy` field of an entry in the `iam_policies` list by referencing: `module.iam_role.iam_standard_policies.[POLICY_NAME]` | `Map` |

### iam_role
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| id | The [unique ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#GUIDs "AWS documentation") assigned by AWS for the created IAM role | `String` |
| arn | The ARN assigned by AWS for the created IAM role. | `String` |
| name | The name for the created IAM role. | `String` |

### iam_created_policies
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| id | The [unique ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#GUIDs "AWS documentation") assigned by AWS for the created IAM polici | `String` |
| name | The name of the created IAM policy | `String` |
| arn | The ARN assigned by AWS for the created IAM policy. | `String` |