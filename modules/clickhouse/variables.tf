variable "deployment_name" {
  type        = string
  description = "The name of the deployment"
}

variable "clickhouse_security_group_ids" {
  type        = list(string)
  description = "The security group ids for the clickhouse cluster"
}

variable "clickhouse_subnet_id" {
  type        = string
  description = "The subnet id for the clickhouse cluster. Note this can only be one subnet/one AZ since the EBS volume is created in the same subnet and needs to be preserved and reattached if a new instance is created."
}

variable "clickhouse_instance_count" {
  type        = number
  description = "Do not change this unless instructed by Braintrust."
  default     = 1
  validation {
    condition     = var.clickhouse_instance_count > 1
    error_message = "More than 1 instance is not supported."
  }
}

variable "clickhouse_instance_type" {
  type        = string
  description = "The instance type for the clickhouse cluster"
  default     = "c5.2xlarge"
}

variable "clickhouse_instance_key_pair_name" {
  type        = string
  description = "The SSH key pair name for the clickhouse instance. "
  default     = null
}

variable "clickhouse_metadata_storage_size" {
  type        = number
  description = "The size of the metadata storage for the clickhouse cluster"
  default     = 100
}

variable "external_clickhouse_s3_bucket_name" {
  type        = string
  description = "Don't use this unless instructed by Braintrust. If provided, the name of the existing S3 bucket to use for the clickhouse cluster. If not provided, a new bucket will be created."
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encrypting the EBS volumes. If not provided, AWS managed keys will be used."
  default     = null
}
