# EC2
The EC2 module will create new EC2 instances in a subnet with an EBS volume attached provision PKI based login via SSH.
The created instances will be secured using Nitro Enclaves if supported by the instance type and placed into a security group.
Additionally the module may automatically install software or execute commands on the created EC2 instances using a shell supplied shell script.
Standard AMIs are exposed as output from the module to simplify creation of new EC2 instances.
Please see the following links for details:
- [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance "Terraform documentation")
- [aws_ebs_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume "Terraform documentation")
- [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami "Terraform documentation")

## Input
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| ec2\_instances | List of EC2 instances to create defining the subnet and availability zone for each created instance. Please see below for the format. | `List` | `none` | Yes |
| ec2\_ebs\_volume | The EBS volume that will be created for each instance and automatically attached. Please see below for the format. | `Object` | `40GB` | No |
| ec2\_ssh\_key | The SSH key that will be associated with each created instance. Please see below for the format. | `Object` | `none` | Yes |
| ec2\_ami | The id of the AMI that will be used to create each EC2 instance | `String` | `ubuntu` | No |
| ec2\_instance\_type | The type of EC2 instance that will be created. | `String` | `t3.micro` | No |
| ec2\_security\_groups | List of security groups that each created instance will be placed in. | `List` | `empty list` | No |
| ec2\_tags | List of key / value pairs defining the tags for the created EC2 instances | `Map` | `empty map` | No |
| ec2\_key |  | `String` | `none` | No |
| ec2\_iam\_user |  | `String` | `none` | Yes |
| ec2\_use\_enhanced\_monitoring | Flag specifying whether enhanced monitoring is enabled for the created EC2 instances | `Boolean` | `true` | No |
| ec2\_allow\_termination | Flag specifying whether the created EC2 instances may be terminated by Terraform (or another API invoker) | `Boolean` | `true` | No |
| ec2\_use\_nitro\_enclave | Flag specifying whether the created EC2 instances will use Nitro Enclaves for enhanced security. Defaults to `null` which will use of Nitro Enclaves if supported by the specified instance type | `Boolean` | `null` | No |
| ec2\_create\_elastic\_ip | Flag specifying whether to create an Elastic IP for each EC2 instance | `Boolean` | `false` | No |
| ec2\_target\_group\_arn | The Amazon Resource Name (ARN) of the target group to place the created EC2 instance in | `String` | `none` | Yes |
| ec2\_user\_data | The user data to apply to each created EC2 instance. By default packages will be updated using `apk` | `String` | `default` | No |

### ec2_instances
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| subnet | The ID of the subnet the created EC2 instance will be placed in | `String` | `none` | Yes |
| availability\_zone | The name of the availability zone in which the created EC2 instance will be placed | `String` | `none` | Yes |

### ec2_ebs_volume
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| size | The size of the created EBS volume in GB | `Number` | `40` | No |
| type | The EBS type of the created EBS volume | `String` | `gp3` | No |
| mount\_point | The mount point where the created EBS volume will be mounted on the EC2 instance | `String` | `/dev/sdf` | No |

### ec2_ssh_key
| Name | Description | Type  | Default | Required |
| ---- | ----------- |:-----:|:-------:|:--------:|
| name | The name of the SSH key which may be used to log into each of the created EC2 instances | `String` | `none` | Yes |
| public\_key | The public key part of the SSH key which may be used to log into each of the created EC2 instances | `String` | `none` Yes |
| create | Boolean flag indicating whether the SSH key should be created in AWS | `Boolean` | `false` | No |

## Output
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| ec2\_standard\_amis | List of IDs for the standard AMIs that are exposed by the module  | `String` |
| ec2\_instances | List of created EC2 instances. Please see below for the format. | `List` |
| ec2\_ssh\_key | The created SSH key that may be used to access the provisioned EC2 instances. Please see below for the format. | `List` |

### ec2_instances
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| id | The id of the created EC2 instance | `String` |
| arn | The Amazon Resource Name (ARN) of the created EC2 instance. Will be of format: `arn:aws:ec2:::[EC2 ID]` | `String` |
| ebs | The ID of the created EBS volume that has been attached to the EC2 instance | `String` |
| subnet | The ID of the subnet in which the created EC2 instance was placed | `String` |
| availability\_zone | The ID of the availability zone in which the created EC2 instance was placed | `String` |
| private\_ip | The private IP assigned to the created EC2 instance | `String` |
| public\_ip | The public IP assigned to the created EC2 instance. Please note that this field will be empty unless the input parameter: `ec2_create_elastic_ip` was set to `true` | `String` |

### ec2_ssh_key
| Name | Description | Type  |
| ------------- | ------------- |:-----:|
| id | The id of the created key pair | `String` |
| arn | The Amazon Resource Name (ARN) of the created key pair. Will be of format: `arn:aws:kms:::[KEY PAIR ID]` | `String` |