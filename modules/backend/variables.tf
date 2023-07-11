variable "aws-region" {
  description = "Aws region to use to create resources"
  default     = "us-east-1"
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

variable "stage_name" {
  type        = string
  default     = "prod"
  description = "API Stage Name"
}


variable "aws_acm_cert" {
  type        = string
  default     = ""
  description = "ACM certificate arn"
}
