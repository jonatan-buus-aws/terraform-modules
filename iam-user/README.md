# IAM User
The IAM User module will create a new IAM group and associate it with  the provided list of IAM users.
Please see the following links for details:
- [Create IAM Policies](https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy "Terraform documentation")
- [aws_iam_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group "Terraform documentation")
- [aws_iam_group_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership "Terraform documentation")
- [aws_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user "Terraform documentation")
- [iam_user_login_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile "Terraform documentation")
- [iam_user_ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_ssh_key "Terraform documentation")
- [iam_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key "Terraform documentation")
- [keybase.io](https://keybase.io "End-to-end encryption for things that matter")

## Input
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| iam\_group | The properties of the created IAM group, see below for details | `Object` | `none` | Yes |
| iam\_temp\_path | The absolute path to a temporary directory where Terraform may write files. Defaults to current working directory. | `String` | `path.cwd` | No |
| iam\_users | List of objects representing the users that will be created and associated with the IAM group | `List` | `empty list` | No |
| iam\_tags | List of key / value pairs defining the tags for the created IAM policies and IAM users | `Map` | `empty list` | No |
| iam\_policies | List of objects representing the policies that will be created and associated with the created IAM group. | `List` | `empty list` | No |

### iam_group
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| name | The name  of the created IAM group. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: `=,.@-_.`. Group names are not distinguished by case. For example, you cannot create groups named both `ADMINS` and `admins` | `String` | `none` | Yes |
| path | The path in which the IAM group will be created. | `String` | `/[GROUP NAME]/` | No |

### iam_users
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| username |  | `String` | `none` | Yes |
| path | The path in which the IAM user will be created. | `String` | `/[GROUP NAME]/users/` | No |
| login\_key | Either a base-64 encoded PGP public key (in a single line), or a keybase username in the form `keybase:[KEYBASE_USERNAME]`. The specific key stored in keybase may be specified by adding `#` after the username and using either the key fingerprint or position starting from 1. I.e. `keybase:[KEYBASE_USERNAME]#[FINGERPRINT]` or `keybase:[KEYBASE_USERNAME]#[POSITION]` | `String` | `none` | `String` | `none` | No |
| access\_key | Either a base-64 encoded PGP public key (in a single line), or a keybase username in the form `keybase:[KEYBASE_USERNAME]`. The specific key stored in keybase may be specified by adding `#` after the username and using either the key fingerprint or position starting from 1. I.e. `keybase:[KEYBASE_USERNAME]#[FINGERPRINT]` or `keybase:[KEYBASE_USERNAME]#[POSITION]` | `String` | `none` | No |
| ssh\_public9\_key | The SSH public key assigned to the created IAM user. The public key must be encoded in ssh-rsa format or PEM format | `String` | `none` | Yes |
| ssh\_key\_format | Specifies the public key encoding format to use in the response. To retrieve the public key in ssh-rsa format, use `SSH`. To retrieve the public key in PEM format, use `PEM`. | `String` | `none` | Yes |

### iam_policies
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| name | The name of the created IAM policy | `String` | `none` | Yes |
| description | Description of the created IAM policy | `String` | `Policy for group: [GROUP NAME]` | No |
| path | The path in which the IAM policy will be created. See [IAM Identifiers](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html "AWS documentation") for more information. | `String` | `/[GROUP NAME]/policies/` | No |
| policy | The policy document as a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the [AWS IAM Policy Document Guide](https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy "Terraform documentation") | `String` | `none` | Yes |

## Output
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| iam\_group | Object representing the created IAM group, see below for details. | `Object` |
| iam\_users | Map of objects with the username as the key representing the created IAM users, see below for details | `Map` |
| iam\_created\_policies | Map of objects with the policy name as the key representing the created IAM policies, see below for details | `Map` |
| iam\_standard\_policies | The list of generated standard IAM policies: `read_only`, `admin` or `ec2_instance_profile` in JSON format. These policies may be passed as input to the module through the `policy` field of an entry in the `iam_policies` list by referencing: `module.iam_user.iam_standard_policies.[POLICY_NAME]` | `Map` |

### iam_group
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| id | The [unique ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#GUIDs "AWS documentation") assigned by AWS for the created IAM group | `String` |
| arn | The ARN assigned by AWS for the created IAM group. | `String` |

### iam_users
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| id | The [unique ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#GUIDs "AWS documentation") assigned by AWS for the created IAM user | `String` |
| name | The name of the created IAM user | `String` |
| arn | The ARN assigned by AWS for the created IAM user. | `String` |
| login | The login for the created IAM user, see below for details | `Object` |
| access\_key | The access key for the created IAM user, see below for details | `Object` |
| ssh\_key\_fingerprint | The MD5 message digest of the SSH public key for the created IAM user | `String` |

### login
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| fingerprint | The fingerprint of the PGP key used to encrypt the password. | `String` |
| encrypted\_password | The encrypted password, base64 encoded, if pgp_key was specified. This attribute is not available for imported resources. The encrypted password may be decrypted using the command line, for example: `terraform output -raw encrypted_password | base64 --decode | keybase pgp decrypt`. | `String` |
| password | The descrypted password for the created login. Please note that this property is only available if the login key was created using keybase otherwise it will be `null`. | `String` |

### access_key
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| fingerprint | The fingerprint of the PGP key used to encrypt the secret. | `String` |
| encrypted\_secret | The encrypted secret, base64 encoded, if pgp_key was specified. This attribute is not available for imported resources. The encrypted secret may be decrypted using the command line, for example: `terraform output -raw encrypted_secret | base64 --decode | keybase pgp decrypt`. | `String` |
| secret | The descrypted secret for the created access key. Please note that this property is only available if the access key was created using keybase otherwise it will be `null`. | `String` |

### iam_created_policies
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| id | The [unique ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#GUIDs "AWS documentation") assigned by AWS for the created IAM polici | `String` |
| name | The name of the created IAM policy | `String` |
| arn | The ARN assigned by AWS for the created IAM policy. | `String` |