variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "eu-north-1"
}

variable "project_name" {
  description = "The name of the project, used for naming resources"
  default     = "btc-usd-pipeline"
}

variable "terraform_state_bucket" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
}

variable "terraform_state_lock_table" {
  description = "The name of the DynamoDB table for Terraform state locking"
  type        = string
}


variable "finnhub_api_key" {
  description = "API key for Finnhub"
  type        = string
}