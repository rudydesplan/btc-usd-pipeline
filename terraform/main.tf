terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-dsti"
    key            = "btc-usd-pipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-table-dsti"
    encrypt        = true
  }
}