output "clickhouse_instance_id" {
  value = try(aws_instance.clickhouse[0].id, null)
}

output "clickhouse_instance_private_ip" {
  value = try(aws_instance.clickhouse[0].private_ip, null)
}

output "clickhouse_secret_arn" {
  value = aws_secretsmanager_secret.clickhouse_secret.arn
}

output "clickhouse_s3_bucket_name" {
  value = try(aws_s3_bucket.clickhouse_s3_bucket[0].id, var.external_clickhouse_s3_bucket_name)
}

output "clickhouse_secret_id" {
  # This is a pipe delimited combination of secret ID and version ID
  # This is unfortunately needed because the AWSCURRENT version alias appears to be eventually consistent.
  # If you try get the secret by ID right after creating it, you will get an error saying AWSCURRENT doesn't exist.
  # So instead you must point directly at the secret id and version id
  description = "The ID of the secret version"
  value       = aws_secretsmanager_secret_version.clickhouse_secret.id
}

output "clickhouse_secret" {
  description = "The secret containing the clickhouse credentials"
  value       = aws_secretsmanager_secret_version.clickhouse_secret.secret_string
}

output "clickhouse_iam_role_arn" {
  description = "The ARN of the IAM role for the Clickhouse instance"
  value       = aws_iam_role.clickhouse.arn
}
