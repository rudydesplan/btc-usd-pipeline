#SNS topic for each bucket

resource "aws_sns_topic" "central_logging_bucket_topic" {
  name = "s3-central-logging-bucket-events"
}

resource "aws_sns_topic" "terraform_state_bucket_topic" {
  name = "s3-terraform-state-bucket-events"
}

resource "aws_sns_topic" "replication_bucket_topic" {
  provider = aws.replication_region
  name     = "s3-replication-bucket-events"
}

#SNS topic policy for each topic to allow S3 to publish messages

resource "aws_sns_topic_policy" "central_logging_bucket_topic_policy" {
  arn = aws_sns_topic.central_logging_bucket_topic.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.central_logging_bucket_topic.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.central_logging_bucket.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_policy" "terraform_state_bucket_topic_policy" {
  arn = aws_sns_topic.terraform_state_bucket_topic.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.terraform_state_bucket_topic.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.terraform_state_bucket.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_policy" "replication_bucket_topic_policy" {
  provider = aws.replication_region
  arn = aws_sns_topic.replication_bucket_topic.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.replication_bucket_topic.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.replication_bucket.arn
          }
        }
      }
    ]
  })
}

#S3 event notifications

resource "aws_s3_bucket_notification" "central_logging_bucket_notification" {
  bucket = aws_s3_bucket.central_logging_bucket.id

  topic {
    topic_arn     = aws_sns_topic.central_logging_bucket_topic.arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix = ".log"
  }

  depends_on = [aws_sns_topic_policy.central_logging_bucket_topic_policy]
}

resource "aws_s3_bucket_notification" "terraform_state_bucket_notification" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  topic {
    topic_arn = aws_sns_topic.terraform_state_bucket_topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_sns_topic_policy.terraform_state_bucket_topic_policy]
}

resource "aws_s3_bucket_notification" "replication_bucket_notification" {
  provider = aws.replication_region
  bucket = aws_s3_bucket.replication_bucket.id

  topic {
    topic_arn = aws_sns_topic.replication_bucket_topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_sns_topic_policy.replication_bucket_topic_policy]
}

#Outputs

output "central_logging_bucket_topic_arn" {
  value       = aws_sns_topic.central_logging_bucket_topic.arn
  description = "The ARN of the SNS topic for central logging bucket events"
}

output "terraform_state_bucket_topic_arn" {
  value       = aws_sns_topic.terraform_state_bucket_topic.arn
  description = "The ARN of the SNS topic for Terraform state bucket events"
}

output "replication_bucket_topic_arn" {
  value       = aws_sns_topic.replication_bucket_topic.arn
  description = "The ARN of the SNS topic for replication bucket events"
}