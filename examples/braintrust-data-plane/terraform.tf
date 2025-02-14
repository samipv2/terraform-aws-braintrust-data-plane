# Example storing terraform state in S3.
# terraform {
#   backend "s3" {
#     # Example: "us-east-1"
#     region         = "<your AWS region>"
#     # Example: "terraform-state-lock"
#     dynamodb_table = "<your-dynamodb-table-name>"
#     # Example: "yourcompany-terraform-state"
#     bucket         = "<s3-bucket-name>"
#     # The path in S3 to store the state of this terraform directory.
#     key = "braintrust"
#   }
# }

# Store terraform state locally. Only use this for local testing.
# Use S3 or other remote backends for production deployments.
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
