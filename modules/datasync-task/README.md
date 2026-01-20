<!-- BEGIN_TF_DOCS -->
# AWS DataSync Task Terraform sub-module

Creates a Datasync Task. A task describes a DataSync transfer. It identifies a source and destination location along with details about how to copy data between those locations. You also can specify how a task treats metadata, deleted files, and permissions.

## Enhanced Mode Support

This module supports AWS DataSync Enhanced Mode for improved performance and capabilities. Enhanced mode provides:

- **Higher Performance**: Parallel listing, preparing, transferring, and verifying of data
- **Unlimited Objects**: No quotas on the number of files/objects per task execution
- **Better Monitoring**: More detailed counters, metrics, and structured JSON logging
- **Optimized Verification**: Only verifies transferred data (not all data)

### Enhanced Mode Requirements

- **Supported Transfers**: S3-to-S3, Azure Blob-to-S3, and other cloud-to-S3 transfers only
- **IAM Permissions**: User must have `iam:CreateServiceLinkedRole` permission
- **Immutable**: Task mode cannot be changed after task creation

### Enhanced Mode Considerations

- **Bandwidth Limits**: Not supported (omit `bytes_per_second` parameter)
- **Object Tags**: `object_tags = "PRESERVE"` is supported for S3-to-S3 and cross-cloud transfers where both locations support object tagging. Enhanced mode will fail immediately if locations don't support tagging. For locations without tag support, set `object_tags = "NONE"`.
- **Verification**: Only `verify_mode = "ONLY_FILES_TRANSFERRED"` or `verify_mode = "NONE"` are supported. `POINT_IN_TIME_CONSISTENT` is not supported with enhanced mode.
- **Failure Handling**: Enhanced mode fails immediately for unsupported object tagging scenarios

For more details, see: [AWS DataSync Task Mode Documentation](https://docs.aws.amazon.com/datasync/latest/userguide/choosing-task-mode.html)

## DataSync Task

To configure one or more AWS DataSync Tasks use the `datasync_tasks` variable. It is a list that supports objects with the following attributes.

- `destination_location_arn` - (Required) Amazon Resource Name (ARN) of destination DataSync Location.
- `source_location_arn` - (Required) Amazon Resource Name (ARN) of source DataSync Location.
- `cloudwatch_log_group_arn` - (Optional) Amazon Resource Name (ARN) of the CloudWatch Log Group that is used to monitor and log events in the sync task.
- `excludes` - (Optional) Filter rules that determines which files to exclude from a task.
- `includes` - (Optional) Filter rules that determines which files to include in a task.
- `name` - (Optional) Name of the DataSync Task.
- `options` - (Optional) Configuration map containing option that controls the default behavior when you start an execution of this DataSync Task. For each individual task execution, you can override these options by specifying an overriding configuration in those executions.
- `schedule` - (Optional) Specifies a schedule used to periodically transfer files from a source to a destination location.
- `tags` - (Optional) Key-value pairs of resource tags to assign to the DataSync Task.
- `task_mode` - (Optional) Determines whether the task runs in BASIC or ENHANCED mode. Enhanced mode provides better performance for S3-to-S3 transfers. Valid values: BASIC, ENHANCED. Default: BASIC.

**Options**

- `atime` - (Optional) A file metadata that shows the last time a file was accessed (that is when the file was read or written to). If set to BEST\_EFFORT, the DataSync Task attempts to preserve the original (that is, the version before sync PREPARING phase) atime attribute on all source files. Valid values: BEST\_EFFORT, NONE. Default: BEST\_EFFORT.
- `bytes_per_second` - (Optional) Limits the bandwidth utilized. For example, to set a maximum of 1 MB, set this value to 1048576. Value values: -1 or greater. Default: -1 (unlimited).
gid - (Optional) Group identifier of the file's owners. Valid values: BOTH, INT\_VALUE, NAME, NONE. Default: INT\_VALUE (preserve integer value of the ID).
- `log_level` - (Optional) Determines the type of logs that DataSync publishes to a log stream in the Amazon CloudWatch log group that you provide. Valid values: OFF, BASIC, TRANSFER. Default: OFF.
mtime - (Optional) A file metadata that indicates the last time a file was modified (written to) before the sync PREPARING phase. Value values: NONE, PRESERVE. Default: PRESERVE.
- `object_tags` - (Optional) Specifies whether object tags are maintained when transferring between object storage systems. If you want your DataSync task to ignore object tags, specify the NONE value. Valid values: PRESERVE, NONE. Default value: PRESERVE. Note: PRESERVE is allowed in enhanced mode only for S3 to S3 and other locations where object tagging is enabled.  
- `overwrite_mode` - (Optional) Determines whether files at the destination should be overwritten or preserved when copying files. Valid values: ALWAYS, NEVER. Default: ALWAYS.
- `posix_permissions` - (Optional) Determines which users or groups can access a file for a specific purpose such as reading, writing, or execution of the file. Valid values: NONE, PRESERVE. Default: PRESERVE.
- `preserve_deleted_files` - (Optional) Whether files deleted in the source should be removed or preserved in the destination file system. Valid values: PRESERVE, REMOVE. Default: PRESERVE.
- `preserve_devices` - (Optional) Whether the DataSync Task should preserve the metadata of block and character devices in the source files system, and recreate the files with that device name and metadata on the destination. The DataSync Task can’t sync the actual contents of such devices, because many of the devices are non-terminal and don’t return an end of file (EOF) marker. Valid values: NONE, PRESERVE. Default: NONE (ignore special devices).
- `security_descriptor_copy_flags` - (Optional) Determines which components of the SMB security descriptor are copied from source to destination objects. This value is only used for transfers between SMB and Amazon FSx for Windows File Server locations, or between two Amazon FSx for Windows File Server locations. Valid values: NONE, OWNER\_DACL, OWNER\_DACL\_SACL. Default: OWNER\_DACL.
- `task_queueing` - (Optional) Determines whether tasks should be queued before executing the tasks. Valid values: ENABLED, DISABLED. Default ENABLED.
transfer\_mode - (Optional) Determines whether DataSync transfers only the data and metadata that differ between the source and the destination location, or whether DataSync transfers all the content from the source, without comparing to the destination location. Valid values: CHANGED, ALL. Default: CHANGED
- `uid` - (Optional) User identifier of the file's owners. Valid values: BOTH, INT\_VALUE, NAME, NONE. Default: INT\_VALUE (preserve integer value of the ID).
- `verify_mode` - (Optional) Whether a data integrity verification should be performed at the end of a task execution after all data and metadata have been transferred. Valid values: NONE, POINT\_IN\_TIME\_CONSISTENT, ONLY\_FILES\_TRANSFERRED. Default: POINT\_IN\_TIME\_CONSISTENT.

**Schedule**
- `schedule_expression` - (Required) Specifies the schedule you want your task to use for repeated executions. For more information, see Schedule Expressions for Rules.

**Excludes**
- `filter_type` - (Optional) The type of filter rule to apply. Valid values: SIMPLE\_PATTERN.
value - (Optional) A single filter string that consists of the patterns to exclude. The patterns are delimited by "|" (that is, a pipe), for example: /folder1|/folder2

**Includes**
- `filter_type` - (Optional) The type of filter rule to apply. Valid values: SIMPLE\_PATTERN.
value - (Optional) A single filter string that consists of the patterns to include. The patterns are delimited by "|" (that is, a pipe), for example: /folder1|/folder2

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datasync_task.datasync_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_datasync_tasks"></a> [datasync\_tasks](#input\_datasync\_tasks) | A list of task configurations | <pre>list(object({<br/>    destination_location_arn = string<br/>    source_location_arn      = string<br/>    cloudwatch_log_group_arn = optional(string)<br/>    excludes                 = optional(object({ filter_type = string, value = string }))<br/>    includes                 = optional(object({ filter_type = string, value = string }))<br/>    name                     = optional(string)<br/>    options                  = optional(map(string))<br/>    schedule_expression      = optional(string)<br/>    tags                     = optional(map(string))<br/>    task_mode                = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datasync_tasks"></a> [datasync\_tasks](#output\_datasync\_tasks) | DataSync Task ARN |
<!-- END_TF_DOCS -->