data "aws_caller_identity" "current" {}

#Versioning not added as per guidnance from the S3 to S3 Cross account tutorial DataSync documentation. Read https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_s3-s3-cross-account-transfer.html
#tfsec:ignore:aws-s3-enable-versioning
module "source-bucket" {
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
    target_bucket = module.s3_log_delivery_bucket.s3_bucket_id
    target_prefix = "log/"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "source-bucket" {
  bucket = module.source-bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.source-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "source-kms" {
  description              = "KMS key for encrypting source S3 buckets"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  enable_key_rotation      = true
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
          "kms:Get*",
          "kms:List*"
        ]
        Effect = "Allow"
        Principal = {
          AWS = [
            "${data.aws_caller_identity.current.arn}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
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
module "s3_log_delivery_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-s3-log-bucket"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-log-bucket" {
  bucket = module.s3_log_delivery_bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.source-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
