variable "aws_region" {
  description = "Specify the AWS region to deploy to"
  type        = string
}

variable "website_bucket_name" {
  description = "Name to assign to the S3 bucket holding site files"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the speed test site"
  type        = string
}

variable "tld" {
  description = "Top-level domain for the speed test site"
  type        = string
}
