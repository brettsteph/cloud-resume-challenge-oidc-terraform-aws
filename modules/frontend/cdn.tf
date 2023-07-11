################
# CloudFront
################
locals {
  # s3_oai_origin_id = "myS3Origin1"
  s3_oac_origin_id = aws_s3_bucket.this.bucket
}
# #######################
# # Create an OAI Policy
# #######################
# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "origin-access-identity-to-Amazon-S3-content"
# }
#######################
# Create an OAC Policy
#######################
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

##################################
# Cache Policy
##################################
data "aws_cloudfront_cache_policy" "cache_policy" {
  # id   = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  name = "Managed-CachingOptimized"
}
##################################
# Create a CloudFront distribution
##################################
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  # origin {
  #   domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
  #   origin_id                = local.s3_oai_origin_id

  #   s3_origin_config {
  #     origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
  #   }
  # }

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = local.s3_oac_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  aliases = [var.sub_domain]

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    target_origin_id       = local.s3_oac_origin_id
    viewer_protocol_policy = "redirect-to-https"

    # Using the CachingDisabled managed policy ID:
    # cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    cache_policy_id = data.aws_cloudfront_cache_policy.cache_policy.id

    compress = true
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  # optional
  # is_ipv6_enabled = true
  # comment             = "Some comment"
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "logs.brettstephen.com.s3.amazonaws.com"
  #   prefix          = "mylogs/"
  # }

  tags = {
    Name = "Terraform - CDN"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
