<!-- BEGIN_TF_DOCS -->
# AWS DataSync Terraform Module

This repository contains Terraform code which creates resources required to run DataSync task (https://https://aws.amazon.com/datasync/) to sync data within AWS and from on premises to AWS or vise-versa.

AWS DataSync supports a wide variety of file and object storage systems on-premise and in AWS to facilitate data transfer.

For on-premises storage transfers : DataSync works with the following on-premises storage systems:

-Network File System (NFS)
-Server Message Block (SMB)
-Hadoop Distributed File Systems (HDFS)
-Object storage

For AWS storage transfers: DataSync works with the following AWS storage services:

-Amazon S3
-Amazon EFS
-Amazon FSx for Windows File Server
-Amazon FSx for Lustre
-Amazon FSx for OpenZFS
-Amazon FSx for NetApp ONTAP

The module requires a source DataSync location and destination Datasync location to be declared. The default location types supported are S3 and EFS. For more details regarding the DataSync Locations S3 and EFS and their respective arguments can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3.html) and [here].(https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_efs).

## [DataSync Locations Module](modules/datasync-locations/)

S3 Location
```hcl
# S3 Datasync location
resource "aws_datasync_location_s3" "s3_location" {
  for_each = {
    for location in var.s3_locations :
    location.name => location # Assign key => value
  }
  s3_bucket_arn    = each.value.s3_bucket_arn
  s3_storage_class = try(each.value.s3_storage_class, null)
  subdirectory     = each.value.subdirectory != null ? each.value.subdirectory : "/"
  tags             = each.value.tags != null ? each.value.tags : {}
  agent_arns       = try(each.value.agent_arns, null)

  s3_config {
    bucket_access_role_arn = each.value.s3_config_bucket_access_role_arn != null ? each.value.s3_config_bucket_access_role_arn : aws_iam_role.datasync_role_s3[each.key].arn
  }

}
```
EFS Locatoin
```hcl
# EFS Datasync location
resource "aws_datasync_location_efs" "efs_location" {
  for_each = {
    for location in var.efs_locations :
    location.name => location # Assign key => value
  }
  efs_file_system_arn = each.value.efs_file_system_arn
  subdirectory        = each.value.subdirectory != null ? each.value.subdirectory : "/"
  tags                = each.value.tags != null ? each.value.tags : {}

  ec2_config {
    subnet_arn          = each.value.ec2_config_subnet_arn
    security_group_arns = each.value.ec2_config_security_group_arns
  }

}
```
Two locations, one as source and other as destination are required for the Datasync task configuration. Once the locations are configured, they need to be passed as source location arn and destination location arn to the next module for Datasync task configuration.

## [DataSync Task Module](modules/datasync-task/)

```hcl
resource "aws_datasync_task" "datasync_tasks" {
  for_each = {
    for index, task in var.datasync_tasks :
    index => task # Assign key => value
  }
  destination_location_arn = each.value.destination_location_arn
  source_location_arn      = each.value.source_location_arn
  cloudwatch_log_group_arn = try(each.value.cloudwatch_log_group_arn, null)

  excludes {
    filter_type = try(each.value.excludes.filter_type, null)
    value       = try(each.value.excludes.value, null)
  }
  includes {
    filter_type = try(each.value.includes.filter_type, null)
    value       = try(each.value.includes.value, null)

  }
  ```

  example :

  ```hcl
  module "backup_tasks" {
  source = "../../modules/datasync-task"
  datasync_tasks = [
    {
      name                     = "s3-logs-backup"
      source_location_arn      = module.s3_location.s3_locations["anycompany-bu1-appl1-logs"].arn
      destination_location_arn = module.s3_location.s3_locations["anycompany-bu1-backups"].arn
      options = {
        posix_permissions = "NONE"
        uid               = "NONE"
        gid               = "NONE"
      }
      schedule_expression = "rate(1 hour)" # Run every hour
      includes = {
        "filter_type" = "SIMPLE_PATTERN"
        "value"       = "/logs/"
      }
      excludes = {
        "filter_type" = "SIMPLE_PATTERN"
        "value"       = "*/temp"
      }
    }
  ]
}
```
Refer to s3 to s3 Datasync example for an end to end example : [s3-to-s3](examples/s3-to-s3/)

## Usage with DataSync Locations and Task module

- Link to S3 to S3 same account sync example for in-cloud sync : [s3-to-s3](examples/s3-to-s3/)
- Link to S3 to S3 cross account sync example for in-cloud sync : [s3-to-s3-cross-account](examples/s3-to-s3-cross-account/)
- Link to EFS to S3 same account sync example for in-cloud sync : [efs-to-s3](examples/efs-to-s3/)
- Link to S3 to EFS same account sync example for in-cloud sync :

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