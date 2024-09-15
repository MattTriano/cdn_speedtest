output "website_bucket_name" {
  value = aws_s3_bucket.website_bucket.id
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website_distribution.id
}

output "website_url" {
  value = local.website_url
}

output "domain_name" {
  value = var.domain_name
}

output "tld" {
  value = var.tld
}

output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
