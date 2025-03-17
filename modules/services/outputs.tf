output "api_url" {
  description = "The primary endpoint for the dataplane API. This is the value that should be entered into the braintrust dashboard under API URL."
  value       = "https://${aws_cloudfront_distribution.dataplane.domain_name}"
}

output "ai_proxy_url" {
  description = "The URL of the AI proxy lambda function"
  value       = aws_lambda_function_url.ai_proxy.function_url
}

output "api_handler_arn" {
  description = "The ARN of the API handler lambda function"
  value       = aws_lambda_function.api_handler.arn
}

output "ai_proxy_arn" {
  description = "The ARN of the AI proxy lambda function"
  value       = aws_lambda_function.ai_proxy.arn
}

output "api_gateway_rest_api_arn" {
  description = "The ARN of the API gateway rest api"
  value       = aws_api_gateway_rest_api.api.arn
}

output "code_bundle_bucket_arn" {
  description = "The ARN of the code bundle bucket"
  value       = aws_s3_bucket.code_bundle_bucket.arn
}

output "lambda_responses_bucket_arn" {
  description = "The ARN of the lambda responses bucket"
  value       = aws_s3_bucket.lambda_responses_bucket.arn
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the cloudfront distribution"
  value       = aws_cloudfront_distribution.dataplane.arn
}
