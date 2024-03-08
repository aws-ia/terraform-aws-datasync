resource "aws_s3_bucket" "appl1-bucket" {
  bucket = "${random_pet.prefix.id}-anycompany-bu1-appl1-bucket"
}

resource "aws_s3_bucket" "anycompany-bu1-backups" {
  bucket = "${random_pet.prefix.id}-anycompany-bu1-backups"
}
