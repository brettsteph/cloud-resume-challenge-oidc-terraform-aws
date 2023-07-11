
output "s3_bucket_name" {
  value = aws_s3_bucket.this.bucket
}

# output "oai" {
#   value = aws_cloudfront_origin_access_identity.oai.iam_arn
# }

output "oac" {
  value = aws_cloudfront_origin_access_control.oac.id
}

output "domain" {
  value = var.domain
}

output "sub_domain" {
  value = var.sub_domain
}

output "aws_acm_cert" {
  value = aws_acm_certificate_validation.validation.certificate_arn
}