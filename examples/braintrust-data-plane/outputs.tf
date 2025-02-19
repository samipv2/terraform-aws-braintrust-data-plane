output "api_url" {
  value       = module.braintrust-data-plane.api_url
  description = "The primary endpoint for the dataplane API. This is the value that should be entered into the braintrust dashboard under API URL."
}
output "clickhouse_s3_bucket_name" {
  value       = module.braintrust-data-plane.clickhouse_s3_bucket_name
  description = "Name of the Clickhouse S3 bucket"
}
