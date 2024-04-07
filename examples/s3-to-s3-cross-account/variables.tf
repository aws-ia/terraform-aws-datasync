variable "region" {
  description = "The name of the region you wish to deploy into"
  default     = "us-east-1"
}

variable "owner_profile" {
  description = "The AWS Profile where all the DataSync resources will be created i.e., DataSync locations, Tasks and Executions"
  default     = "default"
}

variable "cross_account_profile" {
  description = "The AWS Profile for Cross Account where resources needed for the cross account DataSync location configuration are created"
  default     = "cross-account"
}

