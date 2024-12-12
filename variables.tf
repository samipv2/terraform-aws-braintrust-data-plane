locals {
  # Lookup and choose an AZ if not provided
  private_subnet_1_az = var.private_subnet_1_az != null ? var.private_subnet_1_az : data.aws_availability_zones.available.names[0]
  private_subnet_2_az = var.private_subnet_2_az != null ? var.private_subnet_2_az : data.aws_availability_zones.available.names[1]
  private_subnet_3_az = var.private_subnet_3_az != null ? var.private_subnet_3_az : data.aws_availability_zones.available.names[2]
  public_subnet_1_az  = var.public_subnet_1_az != null ? var.public_subnet_1_az : data.aws_availability_zones.available.names[0]

  # Lookup and choose an AZ if not provided for Quarantine VPC
  quarantine_private_subnet_1_az = var.quarantine_private_subnet_1_az != null ? var.quarantine_private_subnet_1_az : data.aws_availability_zones.available.names[0]
  quarantine_private_subnet_2_az = var.quarantine_private_subnet_2_az != null ? var.quarantine_private_subnet_2_az : data.aws_availability_zones.available.names[1]
  quarantine_private_subnet_3_az = var.quarantine_private_subnet_3_az != null ? var.quarantine_private_subnet_3_az : data.aws_availability_zones.available.names[2]
  quarantine_public_subnet_1_az  = var.quarantine_public_subnet_1_az != null ? var.quarantine_public_subnet_1_az : data.aws_availability_zones.available.names[0]
}

variable "deployment_name" {
  default     = "braintrust"
  description = "Name of this Braintrust deployment. Will be included in tags and prefixes in resources names"
}

## NETWORKING
variable "vpc_cidr" {
  default     = "172.29.0.0/16"
  description = "CIDR block for the VPC"
}

variable "private_subnet_1_az" {
  default     = null
  description = "Availability zone for the first private subnet. Leave blank to choose the first available zone"
}

variable "private_subnet_2_az" {
  default     = null
  description = "Availability zone for the first private subnet. Leave blank to choose the second available zone"
}

variable "private_subnet_3_az" {
  default     = null
  description = "Availability zone for the third private subnet. Leave blank to choose the third available zone"
}

variable "public_subnet_1_az" {
  default     = null
  description = "Availability zone for the public subnet. Leave blank to choose the first available zone"
}

variable "enable_quarantine" {
  description = "Enable optional Quarantine VPC. If enabled, user defined functions run inside of this VPC."
  type        = bool
  default     = false
}

variable "quarantine_vpc_cidr" {
  default     = "172.30.0.0/16"
  description = "CIDR block for the Quarantined VPC"
}

variable "quarantine_private_subnet_1_az" {
  default     = null
  description = "Availability zone for the first private subnet. Leave blank to choose the first available zone"
}

variable "quarantine_private_subnet_2_az" {
  default     = null
  description = "Availability zone for the first private subnet. Leave blank to choose the second available zone"
}

variable "quarantine_private_subnet_3_az" {
  default     = null
  description = "Availability zone for the third private subnet. Leave blank to choose the third available zone"
}

variable "quarantine_public_subnet_1_az" {
  default     = null
  description = "Availability zone for the public subnet. Leave blank to choose the first available zone"
}
