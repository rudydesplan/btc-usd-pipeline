variable "msk_cluster_name" {
  description = "The name of the MSK cluster"
  default     = "btc-usd-msk-cluster"
}

variable "aws_mskconnect_connector_name" {
  description = "The name of the MSK Connect Connector"
  default     = "s3-sink-connector"
}

variable "msk_username" {
  description = "Username for MSK authentication"
  type        = string
}

variable "msk_password" {
  description = "Password for MSK authentication"
  type        = string
}

variable "kafka_topic" {
  description = "The Kafka topic to publish to"
  type        = string
  default     = "btc-usd-topic"
}

variable "msk_connect_role_name" {
  description = "The name of the IAM role for MSK Connect"
  default     = "msk_connect_role"
}

variable "msk_connect_policy_name" {
  description = "The name of the IAM policy for MSK Connect"
  default     = "msk_connect_policy"
}

variable "msk_sg_name" {
  description = "The name of the security group for the MSK cluster"
  default     = "msk-sg"
}
