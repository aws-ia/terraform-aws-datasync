##################################################
## Create S3 Bucket for DataSync Source location
##################################################
#Versioning disabled as per guidnance from the S3 to S3 Cross account tutorial DataSync documentation. Read https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_s3-s3-cross-account-transfer.html
#tfsec:ignore:aws-s3-enable-versioning
module "source_bucket" {

  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-source-bucket"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true

  logging = {
    target_bucket = module.source_log_delivery_bucket.s3_bucket_id
    target_prefix = "log/"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "source-bucket" {

  bucket = module.source_bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.source-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "source-kms" {

  description             = "KMS key for encrypting source S3 buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_key_policy" "source-kms-key-policy" {

  key_id = aws_kms_key.source-kms.id
  policy = jsonencode({
    Id = "SourceKMSKeyPolicy"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:PutKeyPolicy",
          "kms:ScheduleKeyDeletion",
          "kms:Get*",
          "kms:List*"
        ]
        Effect = "Allow"
        Principal = {
          AWS = [
            "${aws_iam_role.datasync_dest_s3_access_role.arn}",
            "${module.s3_source_location.datasync_role_arn["source-bucket"]}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.cross-account.account_id}:root"

          ]
        }

        Resource = "${aws_kms_key.source-kms.arn}"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}

##############################################################################
# Create Source S3 bucket for Server Access Logs (Optional if already exists)
##############################################################################

#TFSEC Bucket logging for server access logs supressed. 
#tfsec:ignore:aws-s3-enable-bucket-logging
module "source_log_delivery_bucket" {
  
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-source-log-bucket"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source-log-bucket" {

  bucket = module.source_log_delivery_bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.source-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


################################################
## Create S3 Bucket for Destination location
################################################
#Versioning disabled as per guidnance from the S3 to S3 Cross account tutorial DataSync documentation. Read https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_s3-s3-cross-account-transfer.html
#tfsec:ignore:aws-s3-enable-versioning
module "destination_bucket" {
  providers = {
    aws = aws.destination-account
  }
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-dest-bucket"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true

  logging = {
    target_bucket = module.dest_log_delivery_bucket.s3_bucket_id
    target_prefix = "log/"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "dest-bucket" {
  provider = aws.destination-account
  bucket   = module.destination_bucket.s3_bucket_id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.dest-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "dest-kms" {
  provider                = aws.destination-account
  description             = "KMS key for encrypting destination S3 buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_key_policy" "dest-kms-key-policy" {
  provider = aws.destination-account
  key_id   = aws_kms_key.dest-kms.id
  policy = jsonencode({
    Id = "DestKMSKeyPolicy"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:PutKeyPolicy",
          "kms:ScheduleKeyDeletion",
          "kms:Get*",
          "kms:List*"
        ]
        Effect = "Allow"
        Principal = {
          AWS = [
            "${aws_iam_role.datasync_dest_s3_access_role.arn}",
            "${module.s3_source_location.datasync_role_arn["source-bucket"]}",
            "${data.aws_caller_identity.current.arn}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.cross-account.account_id}:root"
          ]
        }

        Resource = "${aws_kms_key.dest-kms.arn}"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}


###################################################################################
# Create Destination S3 Bucket for Server Access Logs (Optional if already exists)
###################################################################################

#TFSEC Bucket logging for server access logs supressed. 
#tfsec:ignore:aws-s3-enable-bucket-logging
module "dest_log_delivery_bucket" {
  providers = {
    aws = aws.destination-account
  }
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-dest-log-bucket"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dest-log-bucket" {
  provider = aws.destination-account
  bucket   = module.dest_log_delivery_bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.source-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}