# Route 53 Zone
data "aws_route53_zone" "zone" {
  name         = var.domain
  private_zone = false
}
# Find a certificate issued by ACM(not imported into)
data "aws_acm_certificate" "amazon-issued-cert" {
  domain      = var.domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_iam_policy_document" "bucket-policy" {
  # statement {
  #   sid    = "List Bucket & Put Bucket Policy"
  #   effect = "Allow"
  #   principals {
  #     type = "AWS"
  #     identifiers = ["*"]
  #       # "arn:aws:iam::247232402049:user/Terraform"]
  #   }
  #   actions = ["s3:ListBucket", "s3:PutBucketPolicy"]
  #   resources = [
  #   "arn:aws:s3:::${var.s3-bucket-name}"]
  # }
  # statement {
  #   sid    = "PutObject"
  #   effect = "Allow"
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["arn:aws:iam::247232402049:user/Terraform"]
  #   }
  #   actions = ["s3:PutObject"]
  #   resources = [
  #   "arn:aws:s3:::${var.s3-bucket-name}/*"]
  # }
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3-bucket-name}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
  # statement {
  #   sid    = "AllowLegacyOAIReadOnly"
  #   effect = "Allow"
  #   principals {
  #     type = "AWS"
  #     identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
  #   }
  #   actions = ["s3:GetObject"]
  #   resources = [
  #   "arn:aws:s3:::${var.s3-bucket-name}/*"]
  # }
}

