resource "aws_s3_bucket" "source-bucket" {
  provider = aws.cross-account
  bucket   = "${random_pet.prefix.id}-source-bucket"
}

resource "aws_s3_bucket" "dest-bucket" {
  bucket = "${random_pet.prefix.id}-dest-backups"
}
