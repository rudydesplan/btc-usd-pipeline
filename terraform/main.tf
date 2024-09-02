terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "btc-usd-pipeline/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-table"
  }
}

provider "aws" {
  region = var.aws_region
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "btc_usd_logs" {
  name              = "/ecs/btc-usd-fetcher"
  retention_in_days = 7
}
