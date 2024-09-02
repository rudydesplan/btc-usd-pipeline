variable "bronze_layer_bucket_name" {
  description = "The name of the S3 bucket for the Bronze layer"
  default     = "btc-usd-bronze-layer"
}

variable "silver_layer_bucket_name" {
  description = "The name of the S3 bucket for the Silver layer"
  default     = "btc-usd-silver-layer"
}

variable "gold_layer_bucket_name" {
  description = "The name of the S3 bucket for the Gold layer"
  default     = "btc-usd-gold-layer"
}

variable "code_bucket_name" {
  description = "The name of the S3 bucket for storing Glue job scripts"
  default     = "btc-usd-code"
}
