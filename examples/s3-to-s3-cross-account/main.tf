#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

#######################################
#Providers for Source and Dest Accounts
#######################################

provider "aws" {
  alias   = "source-account"
  profile = var.source_account_profile
  region  = var.region
}

provider "aws" {
  alias   = "destination-account"
  region  = var.region
  profile = var.dest_account_profile
}

# random pet prefix to name resources
resource "random_pet" "prefix" {
  length = 2
}

data "aws_caller_identity" "cross-account" {
  provider = aws.destination-account
}

########################################################
# Create Datasync Location IAM role for Source (Dest) Location
########################################################

#TFSEC High warning supressed for IAM policy document uses sensitive action 's3:AbortMultipartUpload' on wildcarded resource. 
# Ref Doc : https://docs.aws.amazon.com/datasync/latest/userguide/create-s3-location.html#create-role-manually
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role" "datasync_dest_s3_access_role" {


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "datasyncAssumeRole"
        Principal = {
          Service = "datasync.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "datasync_inline_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "allowListGetBucket"
          Action = [
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
          ]
          Effect   = "Allow"
          Resource = "${module.destination_bucket.s3_bucket_arn}"
        },
        {
          Sid = "allowBucketObjects"
          Action = [
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:ListMultipartUploadParts",
            "s3:PutObjectTagging",
            "s3:GetObjectTagging",
            "s3:PutObject",
          ],
          Effect   = "Allow"
          Resource = "${module.destination_bucket.s3_bucket_arn}/*"
        },
        {
          Sid = "allowKMSAccess"
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:GenerateDataKey",
            "kms:PutRolePolicy",
            "kms:ScheduleKeyDeletion",
            "kms:Get*",
            "kms:List*"
          ],
          Effect = "Allow"
          Resource = [
            # "${aws_kms_key.source-kms.arn}",
            "${aws_kms_key.dest-kms.arn}"
          ]
        }
      ]
    })

  }
}
##################################################
# Update Bucket policy on cross account S3 Bucket
##################################################

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  provider = aws.destination-account
  bucket   = module.destination_bucket.s3_bucket_id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CrossAccountReadWrite",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
            "${aws_iam_role.datasync_dest_s3_access_role.arn}",
            "${module.s3_source_location.datasync_role_arn["source-bucket"]}",
            "${data.aws_caller_identity.current.arn}"
        ]
      },
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging"
      ],
      "Resource": [
        "${module.destination_bucket.s3_bucket_arn}/*",
        "${module.destination_bucket.s3_bucket_arn}"
        ]
    }
  ]
}
EOF
}
###############################
# Create Datasync S3 locations
###############################

module "s3_source_location" {

  source = "../../modules/datasync-locations"

  s3_locations = [
    {
      name          = "source-bucket"
      s3_bucket_arn = module.source_bucket.s3_bucket_arn # In this example a new S3 bucket is created in s3.tf
      # s3_config_bucket_access_role_arn = aws_iam_role.datasync_source_s3_access_role.arn
      subdirectory             = "/"
      create_role              = true
      s3_source_bucket_kms_arn = aws_kms_key.source-kms.arn
      s3_dest_bucket_kms_arn   = aws_kms_key.dest-kms.arn
      tags                     = { project = "datasync-module" }
    }
  ]
  #depends_on = [aws_s3_bucket_policy.allow_access_from_another_account]

}

module "s3_dest_location" {
  source = "../../modules/datasync-locations"
  s3_locations = [
    {
      name                             = "dest-bucket"
      s3_bucket_arn                    = module.destination_bucket.s3_bucket_arn # In this example a new S3 bucket is created in s3.tf
      s3_config_bucket_access_role_arn = aws_iam_role.datasync_dest_s3_access_role.arn
      subdirectory                     = "/"
      create_role                      = false
      # s3_source_bucket_kms_arn = aws_kms_key.source-kms.arn
      # s3_dest_bucket_kms_arn   = aws_kms_key.dest-kms.arn
      tags = { project = "datasync-module" }
    }
  ]
  depends_on = [aws_s3_bucket_policy.allow_access_from_another_account]

}

#######################
# Create DataSync Task
#######################

module "backup_tasks" {
  source = "../../modules/datasync-task"


  datasync_tasks = [
    {
      name                     = "s3_to_s3_cross_account_task"
      source_location_arn      = module.s3_source_location.s3_locations["source-bucket"].arn
      destination_location_arn = module.s3_dest_location.s3_locations["dest-bucket"].arn
      options = {
        posix_permissions = "NONE"
        uid               = "NONE"
        gid               = "NONE"
      }
      schedule_expression = "rate(1 hour)" # Run every hour
      includes = {
        "filter_type" = "SIMPLE_PATTERN"
        "value"       = "/projects/important-folder"
      }
      excludes = {
        "filter_type" = "SIMPLE_PATTERN"
        "value"       = "*/work-in-progress"
      }
    }
  ]
}


