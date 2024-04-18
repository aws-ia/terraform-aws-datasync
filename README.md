<!-- BEGIN_TF_DOCS -->
# Terraform Module Project

:no\_entry\_sign: Do not edit this readme.md file. To learn how to change this content and work with this repository, refer to CONTRIBUTING.md

## Readme Content

This file will contain any instructional information about this module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0, < 5.0.0 |

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
| <a name="input_efs_locations"></a> [efs\_locations](#input\_efs\_locations) | A list of EFS locations and associated configuration | <pre>list(object({<br>    name                           = string<br>    access_point_arn               = optional(string)<br>    ec2_config_security_group_arns = list(string)<br>    ec2_config_subnet_arn          = string<br>    efs_file_system_arn            = string<br>    file_system_access_role_arn    = optional(string)<br>    in_transit_encryption          = optional(string)<br>    subdirectory                   = optional(string)<br>    tags                           = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_s3_locations"></a> [s3\_locations](#input\_s3\_locations) | A list of S3 locations and associated configuration | <pre>list(object({<br>    name                             = string<br>    agent_arns                       = optional(list(string))<br>    s3_bucket_arn                    = string<br>    s3_config_bucket_access_role_arn = optional(string)<br>    s3_storage_class                 = optional(string)<br>    subdirectory                     = optional(string)<br>    tags                             = optional(map(string))<br>    create_role                      = optional(bool)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datasync_role_arn"></a> [datasync\_role\_arn](#output\_datasync\_role\_arn) | n/a |
| <a name="output_efs_locations"></a> [efs\_locations](#output\_efs\_locations) | n/a |
| <a name="output_s3_locations"></a> [s3\_locations](#output\_s3\_locations) | n/a |
<!-- END_TF_DOCS -->