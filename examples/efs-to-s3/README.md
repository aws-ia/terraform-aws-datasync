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
| <a name="module_efs_location"></a> [efs\_location](#module\_efs\_location) | ../../modules/datasync-locations | n/a |
| <a name="module_s3_location"></a> [s3\_location](#module\_s3\_location) | ../../modules/datasync-locations | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.efs_subnet_mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_security_group.MyEfsSecurityGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_pet.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_efs_security_group_egress_cidr_block"></a> [efs\_security\_group\_egress\_cidr\_block](#input\_efs\_security\_group\_egress\_cidr\_block) | IPv4 CIDR block for egress traffic for EFS and Datasync security group | `string` | `"0.0.0.0/0"` | no |
| <a name="input_my_s3_locations"></a> [my\_s3\_locations](#input\_my\_s3\_locations) | A list of S3 locations and associated configuration | <pre>list(object({<br>    name             = string<br>    s3_bucket_arn    = string<br>    s3_storage_class = optional(string)<br>    subdirectory     = optional(string)<br>    tags             = optional(map(string))<br>    create_role      = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_subnet-count"></a> [subnet-count](#input\_subnet-count) | Number of sunbets per type | `number` | `1` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR block for the creation of example VPC and subnets | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_my_efs_locations"></a> [my\_efs\_locations](#output\_my\_efs\_locations) | DataSync EFS Location ARN |
| <a name="output_my_s3_locations"></a> [my\_s3\_locations](#output\_my\_s3\_locations) | DataSync S3 Location ARN |
<!-- END_TF_DOCS -->