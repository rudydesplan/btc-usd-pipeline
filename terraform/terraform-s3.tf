# Declare the S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-state-bucket-dsti"

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

  # Enable Public Access Block
  block_public_access {
    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
    restrict_public_buckets = true
  }

  # Enable access logging (specify another bucket for logs)
  logging {
    target_bucket = aws_s3_bucket.terraform_logging_bucket.bucket
    target_prefix = "terraform-state-access-logs/"
  }

  # Enable lifecycle configuration for cleaning up old versions of objects
  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 30  # Cleanup non-current versions after 30 days
    }

    expiration {
      days = 365  # Cleanup objects after 365 days
    }
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Development"
  }
}

# Create a new S3 bucket for storing access logs
resource "aws_s3_bucket" "terraform_logging_bucket" {
  bucket = "terraform-logging-bucket-dsti"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "Terraform Logging Bucket"
    Environment = "Development"
  }
}

# Output the logging bucket name
output "logging_bucket_name" {
  value       = aws_s3_bucket.terraform_logging_bucket.bucket
  description = "The name of the logging bucket for Terraform state"
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
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "Terraform Replication Bucket"
    Environment = "Development"
  }
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
          "arn:aws:s3:::${aws_s3_bucket.terraform_state_bucket.bucket}/*"  # Source bucket
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
        Resource = "arn:aws:s3:::${aws_s3_bucket.replication_bucket.bucket}/*"  # Destination bucket
      }
    ]
  })
}

# Cross-region replication configuration for the Terraform state bucket
resource "aws_s3_bucket_replication_configuration" "replication" {
  role = aws_iam_role.replication_role.arn

  rules {
    id     = "ReplicationRule"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replication_bucket.arn  # Destination bucket ARN
      storage_class = "STANDARD"
    }

    filter {
      prefix = ""  # Replicate all objects
    }
  }

  depends_on = [aws_s3_bucket.terraform_state_bucket, aws_s3_bucket.replication_bucket]
}