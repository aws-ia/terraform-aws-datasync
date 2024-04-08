##################################################
## Create S3 Bucket for DataSync Source location
##################################################

# resource "aws_s3_bucket" "appl1-bucket" {
#   bucket = "${random_pet.prefix.id}-anycompany-bu1-appl1-bucket"
# }

#Versioning not added as per guidnance from the S3 to S3 Cross account tutorial DataSync documentation. Read https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_s3-s3-cross-account-transfer.html
#tfsec:ignore:aws-s3-enable-versioning
module "appl1-bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-anycompany-bu1-appl1-bucket"
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
  bucket   = module.appl1-bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.appl1-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "appl1-kms" {
  description             = "KMS key for encrypting source S3 buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}


##############################################################################
# Create Source S3 bucket for Server Access Logs (Optional if already exists)
##############################################################################

#TFSEC Bucket logging for server access logs supressed. 
#tfsec:ignore:aws-s3-enable-bucket-logging
module "source_log_delivery_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-anycompany-bu1-appl1-log-bucket"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "appl1-log-bucket" {
  bucket   = module.source_log_delivery_bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.backup-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


######################################################
## Create S3 Bucket for DataSync Destination location
######################################################

# resource "aws_s3_bucket" "anycompany-bu1-backups" {
#   bucket = "${random_pet.prefix.id}-anycompany-bu1-backups"
# }

#Versioning not added as per guidnance from the S3 to S3 Cross account tutorial DataSync documentation. Read https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_s3-s3-cross-account-transfer.html
#tfsec:ignore:aws-s3-enable-versioning
module "backup-bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-anycompany-bu1-backups"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "backup-bucket" {
  bucket   = module.backup-bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.backup-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "backup-kms" {
  description             = "KMS key for encrypting source S3 buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

##############################################################################
# Create Destination S3 bucket for Server Access Logs (Optional if already exists)
##############################################################################

#TFSEC Bucket logging for server access logs supressed. 
#tfsec:ignore:aws-s3-enable-bucket-logging
module "dest_log_delivery_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = ">=3.5.0"
  bucket                   = "${random_pet.prefix.id}-anycompany-bu1-backups-log-bucket"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "backup-log-bucket" {
  bucket   = module.dest_log_delivery_bucket.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.backup-kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}