# Specify the required Terraform version
terraform {
  required_version = ">= 1.9.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  # Replace with your preferred region
}

provider "aws" {
  alias  = "replication_region"
  region = "eu-north-1"
}

# Data source to get the current AWS account ID
data "aws_caller_identity" "current" {}

# Create a KMS key for DynamoDB encryption (if required for other use cases)
resource "aws_kms_key" "dynamodb_encryption_key" {
  description             = "KMS key for DynamoDB table encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow DynamoDB to use the key"
        Effect = "Allow"
        Principal = {
          Service = "dynamodb.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:CallerAccount" = data.aws_caller_identity.current.account_id
            "kms:ViaService"    = "dynamodb.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Data source to get the current AWS region
data "aws_region" "current" {}

# Output the KMS key ARN
output "kms_key_arn" {
  value       = aws_kms_key.dynamodb_encryption_key.arn
  description = "The ARN of the KMS key used for DynamoDB encryption"
}
