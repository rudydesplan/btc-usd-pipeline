# Dedicated S3 bucket for storing access logs (No logging on this bucket)
resource "aws_s3_bucket" "central_logging_bucket" {
  bucket = "terraform-central-logging-bucket-dsti"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    expiration {
      days = 365
    }
  }

  tags = {
    Name        = "Central Logging Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_public_access_block" "central_logging_bucket_public_access_block" {
  bucket = aws_s3_bucket.central_logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Declare the S3 bucket for Terraform state storage
# Declare the S3 bucket for Terraform state storage with replication configuration
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-state-bucket-dsti"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"  # Updated to use KMS for encryption
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.central_logging_bucket.bucket
    target_prefix = "terraform-state-access-logs/"
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
    expiration {
      days = 365
    }
  }

  # Replication configuration directly in the terraform_state_bucket resource
  replication_configuration {
    role = aws_iam_role.replication_role.arn

    rules {
      id     = "ReplicationRule"
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.replication_bucket.arn
        storage_class = "STANDARD"
      }

      filter {
        prefix = ""  # Replicate all objects
      }
    }
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Development"
  }
}


resource "aws_s3_bucket_public_access_block" "terraform_state_bucket_public_access_block" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Create a destination bucket in another region for cross-region replication
provider "aws" {
  alias  = "replication_region"
  region = "eu-north-1"
}

resource "aws_s3_bucket" "replication_bucket" {
  provider = aws.replication_region
  bucket   = "terraform-state-replication-bucket-dsti"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"  # Updated to use KMS for encryption
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.central_logging_bucket.bucket
    target_prefix = "replication-access-logs/"
  }

  lifecycle_rule {
    enabled = true
    expiration {
      days = 365
    }
  }

  tags = {
    Name        = "Terraform Replication Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_public_access_block" "replication_bucket_public_access_block" {
  provider = aws.replication_region
  bucket = aws_s3_bucket.replication_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for cross-region replication
resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "s3.amazonaws.com"
      },
      Effect   = "Allow",
      Sid      = ""
    }]
  })
}

# Attach the necessary policy for the role to allow replication
resource "aws_iam_role_policy" "replication_policy" {
  role = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.terraform_state_bucket.bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.terraform_state_bucket.bucket}"
      },
      {
        Effect = "Allow",
        Action = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.replication_bucket.bucket}/*"
      }
    ]
  })
}

# Outputs
output "central_logging_bucket_name" {
  value       = aws_s3_bucket.central_logging_bucket.id
  description = "The name of the central logging bucket"
}

output "central_logging_bucket_arn" {
  value       = aws_s3_bucket.central_logging_bucket.arn
  description = "The ARN of the central logging bucket"
}

output "terraform_state_bucket_name" {
  value       = aws_s3_bucket.terraform_state_bucket.id
  description = "The name of the Terraform state bucket"
}

output "terraform_state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state_bucket.arn
  description = "The ARN of the Terraform state bucket"
}

output "replication_bucket_name" {
  value       = aws_s3_bucket.replication_bucket.id
  description = "The name of the replication bucket"
}

output "replication_bucket_arn" {
  value       = aws_s3_bucket.replication_bucket.arn
  description = "The ARN of the replication bucket"
}

output "central_logging_bucket_public_access_block_status" {
  value       = aws_s3_bucket_public_access_block.central_logging_bucket_public_access_block
  description = "Public access block configuration for the central logging bucket"
}

output "terraform_state_bucket_public_access_block_status" {
  value       = aws_s3_bucket_public_access_block.terraform_state_bucket_public_access_block
  description = "Public access block configuration for the Terraform state bucket"
}

output "replication_bucket_public_access_block_status" {
  value       = aws_s3_bucket_public_access_block.replication_bucket_public_access_block
  description = "Public access block configuration for the replication bucket"
}