variable "region" {
  description = "The name of the region you wish to deploy into"
  default     = "us-east-1"
}

variable "source_account_profile" {
  description = "The AWS Profile for Destination Account where all the DataSync resources will be created i.e., DataSync locations, Tasks and Executions"
  default     = "source-account"
}

variable "dest_account_profile" {
  description = "The AWS Profile for Source Account where resources needed for the source DataSync location configuration are created"
  default     = "destination-account"
}

