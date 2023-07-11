output "dynamodb_table" {
  value = aws_dynamodb_table.table.arn
}

output "api_gw_domain_name" {
  description = "API Gateway Domain Name"
  value       = aws_api_gateway_domain_name.api.domain_name
}
output "api_gw_regional_domain_name" {
  description = "API Gateway Regional Domain Name"
  value       = aws_api_gateway_domain_name.api.regional_domain_name
}
output "api_gw_regional_zone_id" {
  description = "API Gateway Regional Zone ID"
  value       = aws_api_gateway_domain_name.api.regional_zone_id
}
