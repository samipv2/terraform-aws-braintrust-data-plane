variable "brainstore_license_key" {
  description = "The license key for the Brainstore instance. You can get this from the Braintrust UI in Settings > API URL."
  type        = string
  validation {
    condition     = var.brainstore_license_key != null && var.brainstore_license_key != ""
    error_message = "The brainstore_license_key must be set."
  }
}

