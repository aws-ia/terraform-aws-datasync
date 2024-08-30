<!-- BEGIN_TF_DOCS -->
# AWS DataSync Terraform Module

This repository contains Terraform code which creates resources required to run a [DataSync task](https://https://aws.amazon.com/datasync/) to sync data within AWS and from on premises to AWS or vise-versa.

AWS DataSync supports a wide variety of file and object storage systems on-premise and in AWS to facilitate data transfer.

For on-premises storage transfers : DataSync works with the following on-premises storage systems:

- Network File System (NFS)
- Server Message Block (SMB)
- Hadoop Distributed File Systems (HDFS)
- Object storage

For AWS storage transfers: DataSync works with the following AWS storage services:

- Amazon S3
- Amazon EFS
- Amazon FSx for Windows File Server
- Amazon FSx for Lustre
- Amazon FSx for OpenZFS
- Amazon FSx for NetApp ONTAP

The module requires a source DataSync location and destination Datasync location to be declared. The location types supported in the examples are S3 and EFS. For more details regarding the DataSync Locations S3 and EFS and their respective arguments can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3.html) and [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_efs).

## Usage with DataSync Locations and Task Module

- Link to EFS to S3 same account sync example for in-cloud transfers : [efs-to-s3](examples/efs-to-s3/)

### [DataSync Locations Module](modules/datasync-locations/)

S3 Location

```hcl
module "s3_location" {
  source = "../../modules/datasync-locations"
  s3_locations = [
    {
      name = "datasync-s3"
      s3_bucket_arn            = "terraform-s3-bucket-12345"
      subdirectory             = "/"
      create_role              = true
      s3_source_bucket_kms_arn = "aws_kms_key_arn"

      tags = { project = "datasync-module" }
    }
  ]
}
```

Note that the Datasync S3 locations module allows you to create a DataSync IAM role by setting `create_role = true`. This IAM role has the required [S3 permissions](https://docs.aws.amazon.com/datasync/latest/userguide/create-s3-location.html#create-role-manually) allowing DataSync service to seamlessly access the S3 bucket.

EFS Location

```hcl
module "efs_location" {
  source = "../../modules/datasync-locations"
  efs_locations = [
    {
      name = "datasync-efs"
      # In this example a new EFS file system is created in efs.tf
      efs_file_system_arn            = "arn:aws:elasticfilesystem:us-east-1:123456789012:filesystem/fs-123456789"
      ec2_config_subnet_arn          = "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-1234567890abcde"
      ec2_config_security_group_arns = [arn:aws:ec2:us-east-1:123456789012:security-group/sg-1234567890abcde]
      tags                           = { project = "datasync-module" }
    }
  ]

  # The mount target should exist before we create the EFS location
  depends_on = [aws_efs_mount_target.efs_subnet_mount_target]

}
```

The examples also includes "aws\_kms\_key" resource block to create a KMS key with a key policy that restricts the use of the key based on same account and cross account access requirements. Refer to this [link](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html) for information.

### [DataSync Task Module](modules/datasync-task/)

Two locations, one as source and other as destination are required for the [Datasync task configuration](https://docs.aws.amazon.com/datasync/latest/userguide/create-task-how-to.html). Once the locations are configured, they need to be passed as source location arn and destination location arn to the next module for Datasync task configuration.For more details regarding the DataSync Task configuration and their respective arguments can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task).

  Example :

```hcl
module "backup_tasks" {
  source = "../../modules/datasync-task"
  datasync_tasks = [
    {
      name                     = "efs_to_s3"
      source_location_arn      = module.s3_location.s3_locations["datasync-s3"].arn
      destination_location_arn = module.efs_location.efs_locations["datasync-efs"].arn
        options = {
          posix_permissions = "NONE"
          uid               = "NONE"
          gid               = "NONE"
        }
      schedule_expression = "cron(0 6 ? * MON-FRI *)" # Run at 6:00 am (UTC) every Monday through Friday:
    }
  ]
}
```

## Example with DataSync Locations and Task module in a Cross Account Use Case

AWS DataSync can transfer data between Amazon S3 buckets that belong to different AWS accounts. Here's what a cross-account transfer using DataSync can look like :

- Source account: The AWS account for managing the S3 bucket that you need to transfer data from.
- Destination account: The AWS account for managing the S3 bucket that you need to transfer data to.

With the launch of the S3 feature Amazon S3 Object Ownership, S3 bucket-level settings can be used to disable access control lists (ACLs) and take ownership of every object in your bucket. It is no longer necessary to configure a cross-account AWS DataSync task to ensure that the destination account owns all of the objects copied over to its S3 bucket. Now, you can just use S3 Object Ownership to ensure that your destination account automatically owns all of the objects copied over to its S3 bucket.

It's important that all the data that you transfer to the S3 bucket from another account belongs to your destination account. To ensure that this account owns the data, disable the bucket's access control lists (ACLs) prior to the data transfer.

This example creates the necessary DataSync resources, including DataSync locations (Source and Destination), Task, and associated IAM roles for S3 access in the source AWS account. The resources related to the destination location (target S3 bucket) are created in the Destination AWS account. It uses IAM policies and resource-based bucket policies to manage cross-account access to DataSync.

AWS provider is used to interact with the resources in the cross accounts.The AWS Provider can source credentials and other settings from the shared configuration and credentials files. By default, these files are located at `$HOME/.aws/credentials` on Linux and macOS, and `%USERPROFILE%\.aws\config` and `%USERPROFILE%\.aws\credentials` on Windows.

Providers are configured as environment variables as below with the corresponding profiles configured at `~/.aws/credentials`. Here is a quick reference on [how to configure a credential file](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html) and use [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#static-credentials).

**Example of `~/.aws/credentials` file :**

```
[source-account]
aws_access_key_id = xxxxxxxxxx
aws_secret_access_key = xxxxxxxxxxxxx
[destination-account]
aws_access_key_id = xxxxxxxxxx
aws_secret_access_key = xxxxxxxxxxxxx

```

**Environment variables:**

```hcl

variable "source_account_profile" {
  description = "The AWS Profile for Destination Account where all the DataSync resources will be created i.e., DataSync locations, Tasks and Executions"
  default     = "source-account"
}

variable "dest_account_profile" {
  description = "The AWS Profile for Source Account where resources needed for the source DataSync location configuration are created"
  default     = "destination-account"
}

```

**Provider config block:**

```hcl

provider "aws" {
  alias   = "source-account"
  profile = var.source_account_profile
  region  = var.region
}

provider "aws" {
  alias   = "destination-account"
  profile = var.dest_account_profile
  region  = var.region
}

```

To configure DataSync for transferring data between accounts, you need to set up permissions in both the source and destination AWS accounts. In the source account, create an IAM role that allows DataSync to transfer data to the destination account's bucket. In the destination account, update the S3 bucket policy to grant access to the IAM role created in the source account.

Datasync Location and Task Modules are generic and do not have any cross account provider configuration. Therefore, IAM role that gives DataSync the permissions to transfer data to your destination account bucket must be created outside of the module and passed as parameter for source location configuration.

```hcl

module "s3_dest_location" {
  source = "../../modules/datasync-locations"
  s3_locations = [
    {
      name                             = "dest-bucket"
      s3_bucket_arn                    = "terraform-s3-dest-bucket-12345"
      s3_config_bucket_access_role_arn = aws_iam_role.datasync_dest_s3_access_role.arn
      subdirectory                     = "/"
      create_role                      = false
      tags = { project = "datasync-module" }
    }
  ]
  depends_on = [aws_s3_bucket_policy.allow_access_from_another_account]

}
```

By default `create_role` is set to `false` for the destination location as the IAM role is created outside the [DataSync Locations Module](modules/datasync-locations/).

The `depends_on` meta-argument ensures that terraform creates the destination Datasync location only after the destination account S3 bucket policy is updated to allowing the source account IAM role to transfer data to destination account bucket.

**Note:** Task creation would fail if the destination account's S3 bucket policy does not allow the source account's IAM role, as DataSync would verify read/write access to the source and destination S3 buckets before configuring the task.

- Here is an end-to-end example for S3 to S3 cross account data transfers : [s3-to-s3-cross-account](examples/s3-to-s3-cross-account/)

## Other usage examples with DataSync Locations and Task module

- Link to S3 to S3 same account sync example for in-cloud transfers : [s3-to-s3](examples/s3-to-s3/)

## Support & Feedback

DataSync module for Terraform is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the AWS Storage community.

To post feedback, submit feature ideas, or report bugs, please use the [Issues section](https://github.com/aws-ia/terraform-aws-datasync/pulls) of this GitHub repo.

If you are interested in contributing to the Storage Gateway module, see the [Contribution guide](https://github.com/aws-ia/terraform-aws-datasync/blob/dev/CONTRIBUTING.md).

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
| <a name="output_datasync_role_arn"></a> [datasync\_role\_arn](#output\_datasync\_role\_arn) | DataSync Task ARN |
| <a name="output_efs_locations"></a> [efs\_locations](#output\_efs\_locations) | DataSync EFS Location ARN |
| <a name="output_s3_locations"></a> [s3\_locations](#output\_s3\_locations) | DataSync S3 Location ARN |
<!-- END_TF_DOCS -->