variable "glue_database_name" {
  description = "The name of the Glue catalog database"
  default     = "btc_usd_db"
}

variable "glue_crawler_name" {
  description = "The name of the Glue crawler"
  default     = "btc-usd-crawler"
}

variable "glue_job_name" {
  description = "The name of the Glue job"
  default     = "btc-usd-job"
}

variable "glue_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  default     = "/aws-glue/jobs/btc-usd-job"
}

variable "glue_job_max_concurrent_runs" {
  description = "The maximum number of concurrent runs for the Glue job"
  default     = 1
}

variable "glue_crawler_schedule" {
  description = "The schedule for running the Glue crawler (CRON expression)"
  default     = "cron(0 * * * ? *)"
}
