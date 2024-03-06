<!-- BEGIN_TF_DOCS -->
# AWS DataSync Locations Terraform sub-module

Creates a Datasync source or destination Location. DataSync Location defines where the data is copied from or to.

# DataSync Locations supported in this module

- Amazon S3
- Amazon EFS

## S3 Locations

To configure one or more S3 Locations use the `s3_locations` variable. It is a list that supports objects with the following attributes.

- `name` - (Required) A name for the location for reference only. Should be unique.
- `agent_arns` - (Optional) A list of DataSync Agent ARNs with which this location will be associated.
- `s3_bucket_arn` - (Required) Amazon Resource Name (ARN) of the S3 Bucket.
- `s3_config_bucket_access_role_arn` - (Optional) ARN of the IAM Role used to connect to the S3 Bucket. Must be provided if `create_role` is set to false.
- `s3_storage_class` - (Optional) The Amazon S3 storage class that you want to store your files in when this location is used as a task destination.
- `subdirectory` - (Optional) Prefix to perform actions as source or destination.
- `tags` - (Optional) Key-value pairs of resource tags to assign to the DataSync Location.
- `create_role` - (Optional) Whether to create the IAM role for accessing the S3 bucket (true) or provide it directly (false). Default is true. If this is set to `false`, specify an existing IAM role for: `s3_config_bucket_access_role_arn`.

## EFS Locations

To configure one or more EFS Locations use the `efs_locations` variable. It is a list that supports objects with the following attributes.

- `name` - (Required) A name for the location for reference only. Should be unique.
- `access_point_arn` - (Optional) Specifies the Amazon Resource Name (ARN) of the access point that DataSync uses to access the Amazon EFS file system.
- `ec2_config_security_group_arns` - (Required) List of Amazon Resource Names (ARNs) of the EC2 Security Groups that are associated with the EFS Mount Target.
- `ec2_config_subnet_arn` - (Required) Amazon Resource Name (ARN) of the EC2 Subnet that is associated with the EFS Mount Target.
- `efs_file_system_arn` - (Required) Amazon Resource Name (ARN) of EFS File System.
- `file_system_access_role_arn` - (Optional) Specifies an Identity and Access Management (IAM) role that DataSync assumes when mounting the Amazon EFS file system.
- `in_transit_encryption` - (Optional) Specifies whether you want DataSync to use TLS encryption when transferring data to or from your Amazon EFS file system. Valid values are `NONE` and `TLS1_2`.
- `subdirectory` - (Optional) Subdirectory to perform actions as source or destination. Default `/`.
- `tags` - (Optional) Key-value pairs of resource tags to assign to the DataSync Location.

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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datasync_location_efs.efs_location](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_efs) | resource |
| [aws_datasync_location_s3.s3_location](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |
| [aws_iam_role.datasync_role_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_efs_locations"></a> [efs\_locations](#input\_efs\_locations) | A list of EFS locations and associated configuration | <pre>list(object({<br>    name =  string<br>    access_point_arn = optional(string)<br>    ec2_config_security_group_arns = list(string)<br>    ec2_config_subnet_arn = string<br>    efs_file_system_arn = string<br>    file_system_access_role_arn = optional(string)<br>    in_transit_encryption = optional(string)<br>    subdirectory     = optional(string)<br>    tags = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_s3_locations"></a> [s3\_locations](#input\_s3\_locations) | A list of S3 locations and associated configuration | <pre>list(object({<br>    name =  string<br>    agent_arns = optional(list(string))<br>    s3_bucket_arn = string<br>    s3_config_bucket_access_role_arn = optional(string)<br>    s3_storage_class = optional(string)<br>    subdirectory     = optional(string)<br>    tags             = optional(map(string))<br>    create_role      = optional(bool)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efs_locations"></a> [efs\_locations](#output\_efs\_locations) | n/a |
| <a name="output_s3_locations"></a> [s3\_locations](#output\_s3\_locations) | n/a |
<!-- END_TF_DOCS -->