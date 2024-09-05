# Provider configuration
provider "aws" {
  region = "us-east-1"  # Assuming this is your primary region
}

provider "aws" {
  alias  = "replication_region"
  region = "eu-north-1"
}

# Central Logging Bucket
resource "aws_s3_bucket" "central_logging_bucket" {
  #checkov:skip=CKV_AWS_18:No access logging required for logging bucket
  #checkov:skip=CKV_AWS_144:No cross-region replication required for logging bucket
  bucket = "terraform-central-logging-bucket-dsti"

  tags = {
    Name        = "Central Logging Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_versioning" "central_logging_bucket_versioning" {
  bucket = aws_s3_bucket.central_logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "central_logging_bucket_encryption" {
  bucket = aws_s3_bucket.central_logging_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "central_logging_bucket_lifecycle" {
  bucket = aws_s3_bucket.central_logging_bucket.id
  rule {
    id     = "expire_after_365_days_and_abort_multipart"
    status = "Enabled"
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "central_logging_bucket_public_access_block" {
  bucket = aws_s3_bucket.central_logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Terraform State Bucket
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-state-bucket-dsti"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket_encryption" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "terraform_state_bucket_logging" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  target_bucket = aws_s3_bucket.central_logging_bucket.id
  target_prefix = "terraform-state-access-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_bucket_lifecycle" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    id     = "expire_noncurrent_versions_and_abort_multipart"
    status = "Enabled"
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "terraform_state_bucket_replication" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  role   = aws_iam_role.replication_role.arn

  rule {
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

resource "aws_s3_bucket_public_access_block" "terraform_state_bucket_public_access_block" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Replication Bucket
resource "aws_s3_bucket" "replication_bucket" {
  provider = aws.replication_region
  #checkov:skip=CKV_AWS_144:Cross-region replication is already implemented
  bucket   = "terraform-state-replication-bucket-dsti"

  tags = {
    Name        = "Terraform Replication Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_versioning" "replication_bucket_versioning" {
  provider = aws.replication_region
  bucket   = aws_s3_bucket.replication_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replication_bucket_encryption" {
  provider = aws.replication_region
  bucket   = aws_s3_bucket.replication_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "replication_bucket_logging" {
  provider      = aws.replication_region
  bucket        = aws_s3_bucket.replication_bucket.id
  target_bucket = aws_s3_bucket.replication_logging_bucket.id
  target_prefix = "replication-access-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "replication_bucket_lifecycle" {
  provider = aws.replication_region
  bucket   = aws_s3_bucket.replication_bucket.id
  rule {
    id     = "expire_after_365_days_and_abort_multipart"
    status = "Enabled"
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "replication_bucket_public_access_block" {
  provider = aws.replication_region
  bucket   = aws_s3_bucket.replication_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Replication Logging Bucket
resource "aws_s3_bucket" "replication_logging_bucket" {
  provider = aws.replication_region
  #checkov:skip=CKV_AWS_18:No access logging required for logging bucket
  #checkov:skip=CKV_AWS_144:No cross-region replication required for logging bucket
  #checkov:skip=CKV2_AWS_62:No event notifications required for this logging bucket
  bucket   = "terraform-replication-logging-bucket-dsti"

  tags = {
    Name        = "Replication Logging Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_versioning" "replication_logging_bucket_versioning" {
  provider = aws.replication_region
  bucket   = aws_s3_bucket.replication_logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replication_logging_bucket_encryption" {
  provider = aws.replication_region
  bucket   = aws_s3_bucket.replication_logging_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "replication_logging_bucket_lifecycle" {
  provider = aws.replication_region
  bucket   = aws_s3_bucket.replication_logging_bucket.id
  rule {
    id     = "expire_after_365_days_and_abort_multipart"
    status = "Enabled"
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "replication_logging_bucket_public_access_block" {
  provider = aws.replication_region
  bucket   = aws_s3_bucket.replication_logging_bucket.id

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
      Effect = "Allow",
      Sid    = ""
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

output "replication_logging_bucket_name" {
  value       = aws_s3_bucket.replication_logging_bucket.id
  description = "The name of the replication logging bucket"
}

output "replication_logging_bucket_arn" {
  value       = aws_s3_bucket.replication_logging_bucket.arn
  description = "The ARN of the replication logging bucket"
}

output "replication_logging_bucket_public_access_block_status" {
  value       = aws_s3_bucket_public_access_block.replication_logging_bucket_public_access_block
  description = "Public access block configuration for the replication logging bucket"
}