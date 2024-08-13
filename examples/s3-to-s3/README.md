<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backup_tasks"></a> [backup\_tasks](#module\_backup\_tasks) | ../../modules/datasync-task | n/a |
| <a name="module_dest_bucket"></a> [dest\_bucket](#module\_dest\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_dest_log_delivery_bucket"></a> [dest\_log\_delivery\_bucket](#module\_dest\_log\_delivery\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_s3_location"></a> [s3\_location](#module\_s3\_location) | ../../modules/datasync-locations | n/a |
| <a name="module_source_bucket"></a> [source\_bucket](#module\_source\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_source_log_delivery_bucket"></a> [source\_log\_delivery\_bucket](#module\_source\_log\_delivery\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.dest-kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.source-kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.dest-kms-key-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_kms_key_policy.source-kms-key-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.dest-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.dest-log-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.source-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.source-log-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_efs_security_group_egress_cidr_block"></a> [efs\_security\_group\_egress\_cidr\_block](#input\_efs\_security\_group\_egress\_cidr\_block) | IPv4 CIDR block for egress traffic for EFS and Datasync security group | `string` | `"0.0.0.0/0"` | no |
| <a name="input_subnet-count"></a> [subnet-count](#input\_subnet-count) | Number of sunbets per type | `number` | `1` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR block for the creation of example VPC and subnets | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_tasks"></a> [backup\_tasks](#output\_backup\_tasks) | DataSync Task ARN |
| <a name="output_datasync_dest_role_arn"></a> [datasync\_dest\_role\_arn](#output\_datasync\_dest\_role\_arn) | DataSync destination S3 Location access IAM role ARN |
| <a name="output_datasync_src_role_arn"></a> [datasync\_src\_role\_arn](#output\_datasync\_src\_role\_arn) | DataSync source S3 Location access IAM role ARN |
| <a name="output_my_s3_locations"></a> [my\_s3\_locations](#output\_my\_s3\_locations) | DataSync S3 Location ARNs |
<!-- END_TF_DOCS -->