# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  # Replace with your preferred region
}

# Create a DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock-table-dsti"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Output the DynamoDB table name
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_state_lock.name
  description = "The name of the DynamoDB table for Terraform state locking"
}

