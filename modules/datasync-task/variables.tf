variable "datasync_tasks" {
  type = list(object({
    destination_location_arn = string
    source_location_arn      = string
    cloudwatch_log_group_arn = optional(string)
    excludes                 = optional(object({ filter_type = string, value = string }))
    includes                 = optional(object({ filter_type = string, value = string }))
    name                     = optional(string)
    options                  = optional(map(string))
    schedule_expression      = optional(string)
    tags                     = optional(map(string))
  }))
  default     = []
  description = "A list of task configurations"
}