resource "aws_kms_key" "braintrust" {
  description             = "KMS key for encrypting resources in the Braintrust data plane"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "Enable IAM User Permissions"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        }
      ],
      var.additional_key_policies
    )
  })

  tags = {
    Name        = "${var.deployment_name}-main"
    Environment = var.deployment_name
  }
}

resource "aws_kms_alias" "braintrust" {
  name          = "alias/braintrust/${var.deployment_name}"
  target_key_id = aws_kms_key.braintrust.key_id
}

data "aws_caller_identity" "current" {}
