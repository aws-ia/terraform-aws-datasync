#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# S3 Datasync location
resource "aws_datasync_location_s3" "s3_location" {
  for_each = {
    for location in var.s3_locations :
    location.name => location # Assign key => value
  }
  s3_bucket_arn    = each.value.s3_bucket_arn
  s3_storage_class = try(each.value.s3_storage_class, null)
  subdirectory     = each.value.subdirectory != null ? each.value.subdirectory : "/"
  tags             = each.value.tags != null ? each.value.tags : {}
  agent_arns       = try(each.value.agent_arns, null)

  s3_config {
    bucket_access_role_arn = each.value.s3_config_bucket_access_role_arn != null ? each.value.s3_config_bucket_access_role_arn : aws_iam_role.datasync_role_s3[each.key].arn
  }

}

#TFSEC High warning supressed for IAM policy document uses sensitive action 's3:AbortMultipartUpload' on wildcarded resource. 
# Ref Doc : https://docs.aws.amazon.com/datasync/latest/userguide/create-s3-location.html#create-role-manually
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role" "datasync_role_s3" {

  for_each = {
    for index, location in var.s3_locations :
    location.name => location if try(location.create_role, false)
  }

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
          Resource = each.value.s3_bucket_arn
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
          ]
          Effect   = "Allow"
          Resource = "${each.value.s3_bucket_arn}/*"
         }
      ]
    })
  }
}

resource "aws_iam_policy" "datasync_role_kms" {

  for_each = {
    for index, location in var.s3_locations :
    location.name => location if try(location.create_role, false) && try(location.s3_source_bucket_kms != "", false)

  }
  name = "datasync_inline_kms_policy"
  policy = jsonencode({

    Sid    = "allowKMSAccess"
    Effect = "Allow",
    Action = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:PutRolePolicy",
      "kms:Get*",
      "kms:List*"
    ],
    Resource = [
      "${each.value.s3_source_bucket_kms_arn}",
      "${each.value.s3_dest_bucket_kms_arn}"
    ]

  })

}

resource "aws_iam_role_policy_attachment" "datasync_role_kms_policy_attachement" {

  for_each = {
    for index, location in var.s3_locations :
    location.name => location if try(location.create_role, false) && try(location.s3_source_bucket_kms != "", false)

  }

  role       = aws_iam_role.datasync_role_s3[each.key].name
  policy_arn = aws_iam_policy.datasync_role_kms[each.key].arn

}

# EFS Datasync location
resource "aws_datasync_location_efs" "efs_location" {
  for_each = {
    for location in var.efs_locations :
    location.name => location # Assign key => value
  }
  efs_file_system_arn = each.value.efs_file_system_arn
  subdirectory        = each.value.subdirectory != null ? each.value.subdirectory : "/"
  tags                = each.value.tags != null ? each.value.tags : {}

  ec2_config {
    subnet_arn          = each.value.ec2_config_subnet_arn
    security_group_arns = each.value.ec2_config_security_group_arns
  }

}