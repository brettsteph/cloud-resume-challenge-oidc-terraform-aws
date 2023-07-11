# S3
#######################
# Create s3 bucket
#######################
resource "aws_s3_bucket" "this" {
  bucket = var.s3-bucket-name
  tags   = var.s3-tags

  force_destroy = true

}

################################
# S3 Bucket Ownership Controls
################################
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#######################
# Bucket versioning
#######################

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.s3-versioning
  }
}
#######################
# Server side encryption
#######################
resource "aws_s3_bucket_server_side_encryption_configuration" "s3-encryption" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
      # kms_master_key_id = var.kms_master_key_arn
      sse_algorithm = var.sse_algorithm
    }
  }
}
################################
# Website bucket configuration
################################
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.this.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

}

#######################
# Bucket policy
#######################
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket-policy.json
}
#  for now don't upload zip file //TODO
# ######################################################
# # Uploading a file to a bucket with correct mime types
# ######################################################
# resource "aws_s3_object" "lambda" {
#   for_each = fileset("../backend/${path.module}/files/", "**/*.zip")
#   bucket   = aws_s3_bucket.this.id
#   key      = each.value
#   source   = "../backend/${path.module}/files/${each.value}"
#   # The filemd5() function is available in Terraform 0.11.12 and later
#   # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
#   etag = filemd5("../backend/${path.module}/files/${each.value}")
# }

