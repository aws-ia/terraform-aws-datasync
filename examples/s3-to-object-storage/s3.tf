##################################################
## Create S3 Bucket for DataSync Source location
##################################################
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
      sse_algorithm = "aws:kms"
    }
  }
}

##############################################################################
# Create Source S3 bucket for Server Access Logs (Optional if already exists)
##############################################################################

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
