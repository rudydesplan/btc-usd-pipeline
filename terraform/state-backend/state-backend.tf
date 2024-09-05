provider "aws" {
  region = "us-east-1"
}

# Create the S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-state-bucket-dsti" # Make sure this matches your .tf file

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"  # Alternatively, use KMS if needed
      }
    }
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Development"
  }
}

# Enable S3 Bucket Logging to the Central Logging Bucket
resource "aws_s3_bucket_logging" "terraform_state_bucket_logging" {
  bucket        = aws_s3_bucket.terraform_state_bucket.id
  target_bucket = "terraform-central-logging-bucket-dsti"  # Replace with the correct central logging bucket name
  target_prefix = "terraform-state-access-logs/"
}

# Create the DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "terraform-state-lock-table-dsti"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "Development"
  }
}

# Outputs for the state management resources
output "terraform_state_bucket_name" {
  value       = aws_s3_bucket.terraform_state_bucket.id
  description = "The name of the Terraform state bucket"
}

output "terraform_lock_table_name" {
  value       = aws_dynamodb_table.terraform_lock_table.name
  description = "The name of the DynamoDB lock table"
}
