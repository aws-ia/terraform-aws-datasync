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
| <a name="provider_aws.cross-account"></a> [aws.cross-account](#provider\_aws.cross-account) | >= 3.72.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backup_tasks"></a> [backup\_tasks](#module\_backup\_tasks) | ../../modules/datasync-task | n/a |
| <a name="module_dest_log_delivery_bucket"></a> [dest\_log\_delivery\_bucket](#module\_dest\_log\_delivery\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_destination_bucket"></a> [destination\_bucket](#module\_destination\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_s3_dest_location"></a> [s3\_dest\_location](#module\_s3\_dest\_location) | ../../modules/datasync-locations | n/a |
| <a name="module_s3_source_location"></a> [s3\_source\_location](#module\_s3\_source\_location) | ../../modules/datasync-locations | n/a |
| <a name="module_source_bucket"></a> [source\_bucket](#module\_source\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |
| <a name="module_source_log_delivery_bucket"></a> [source\_log\_delivery\_bucket](#module\_source\_log\_delivery\_bucket) | terraform-aws-modules/s3-bucket/aws | >=3.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.datasync_source_s3_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_key.dest-kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.source-kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.dest-kms-key-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_kms_key_policy.source-kms-key-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_s3_bucket_policy.allow_access_from_another_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.dest-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.dest-log-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.source-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.source-log-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.cross-account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cross_account_profile"></a> [cross\_account\_profile](#input\_cross\_account\_profile) | The AWS Profile for Cross Account where resources needed for the cross account DataSync location configuration are created | `string` | `"cross-account"` | no |
| <a name="input_owner_profile"></a> [owner\_profile](#input\_owner\_profile) | The AWS Profile where all the DataSync resources will be created i.e., DataSync locations, Tasks and Executions | `string` | `"default"` | no |
| <a name="input_region"></a> [region](#input\_region) | The name of the region you wish to deploy into | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datasync_dest_role_arn"></a> [datasync\_dest\_role\_arn](#output\_datasync\_dest\_role\_arn) | DataSync Destination S3 Access IAM role ARN |
| <a name="output_datasync_src_role_arn"></a> [datasync\_src\_role\_arn](#output\_datasync\_src\_role\_arn) | DataSync Source S3 Access IAM role ARN |
| <a name="output_datasync_task_arn"></a> [datasync\_task\_arn](#output\_datasync\_task\_arn) | Datasync Task ARN |
| <a name="output_my_s3_dest_locations"></a> [my\_s3\_dest\_locations](#output\_my\_s3\_dest\_locations) | DataSync S3 Destination Location ARN |
| <a name="output_my_s3_source_locations"></a> [my\_s3\_source\_locations](#output\_my\_s3\_source\_locations) | DataSync S3 Source Location ARN |
<!-- END_TF_DOCS -->