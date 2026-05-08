terraform {
  required_version = ">= 1.0.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0.0"
    }
  }
}

# Default provider — source account (where DataSync resources are created)
provider "aws" {
  profile = var.source_account_profile
  region  = var.region
}

# Aliased provider for destination account
provider "aws" {
  alias   = "destination-account"
  profile = var.dest_account_profile
  region  = var.region
}
