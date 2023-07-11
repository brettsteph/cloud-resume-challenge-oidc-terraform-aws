variable "aws-region" {
  description = "Aws region to use to create resources"
  default     = "us-east-1"
}

variable "s3-bucket-name" {
  type        = string
  default     = "cloud-challenge-767"
  description = "An s3 bucket for a static website"
}

variable "s3-bucket-acl" {
  type        = string
  default     = "private"
  description = <<-EOT
    The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply.
    We recommend `private` to avoid exposing sensitive information. Conflicts with `grants`.
   only used if aws_s3_bucket_ownership_controls is not set
   EOT
}

variable "s3-versioning" {
  type        = string
  default     = "Disabled"
  description = ""
}

variable "s3-tags" {
  type        = map(any)
  default     = { Name : "Cloud Resume Challenge" }
  description = "An s3 bucket for a static website"
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`"
}

variable "domain" {
  type        = string
  default     = ""
  description = "Domain name"
}
variable "sub_domain" {
  type        = string
  default     = ""
  description = "Sub Domain name"
}
variable "cdn-description" {
  type        = string
  default     = "Resume Site Cloudfront Distribution"
  description = "Describes what the Cloudfront Distribution is for"
}

variable "api_gw_domain_name" {
  type        = string
  default     = ""
  description = "(optional) describe your variable"
}
variable "api_gw_regional_domain_name" {
  type        = string
  default     = ""
  description = "(optional) describe your variable"
}
variable "api_gw_regional_zone_id" {
  type        = string
  default     = ""
  description = "(optional) describe your variable"
}

