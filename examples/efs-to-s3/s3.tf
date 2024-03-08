resource "aws_s3_bucket" "appl1-bucket" {
  # Use prefix and anycompany-bu1-appl1-bucket to name the bucket
  bucket = "${random_pet.prefix.id}-anycompany-bu1-appl1-bucket"
}
