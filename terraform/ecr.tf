# Create an ECR repository for the BTC/USD fetcher Docker image
resource "aws_ecr_repository" "btc_usd_fetcher" {
  name = "btc-usd-fetcher"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Ensure image tags are immutable to prevent overwriting
  image_tag_mutability = "IMMUTABLE"

  # Ensure encryption using the default AWS-managed KMS key
  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name        = "BTC USD Fetcher"
    Environment = "Development"
  }
}

# Output the ECR repository URL for later use in Docker pushes
output "ecr_repository_url" {
  value       = aws_ecr_repository.btc_usd_fetcher.repository_url
  description = "The URL of the ECR repository for the BTC/USD fetcher"
}

