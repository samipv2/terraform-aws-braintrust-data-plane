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
