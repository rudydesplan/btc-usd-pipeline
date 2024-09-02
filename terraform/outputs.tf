output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.btc_usd_repo.repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.btc_usd_cluster.name
}

output "msk_cluster_arn" {
  description = "The ARN of the MSK cluster"
  value       = aws_msk_cluster.btc_usd_cluster.arn
}

output "msk_bootstrap_brokers" {
  description = "The bootstrap brokers for the MSK cluster"
  value       = aws_msk_cluster.btc_usd_cluster.bootstrap_brokers
}

output "msk_connect_connector_arn" {
  description = "The ARN of the MSK Connect connector"
  value       = aws_mskconnect_connector.s3_sink.arn
}

output "msk_connect_role_arn" {
  description = "The ARN of the IAM role for MSK Connect"
  value       = aws_iam_role.msk_connect_role.arn
}


output "emr_cluster_id" {
  description = "The ID of the EMR cluster"
  value       = aws_emr_cluster.btc_usd_emr.id
}

output "gold_layer_bucket" {
  description = "The name of the S3 bucket for the Gold layer"
  value       = aws_s3_bucket.gold_layer.id
}

output "gold_layer_bucket_arn" {
  description = "The ARN of the S3 bucket for the Gold layer"
  value       = aws_s3_bucket.gold_layer.arn
}

output "gold_layer_bucket_policy_arn" {
  description = "The ARN of the policy for the Gold layer S3 bucket"
  value       = aws_s3_bucket_policy.gold_layer_policy.arn
}


output "silver_layer_bucket" {
  description = "The name of the S3 bucket for the Silver layer"
  value       = aws_s3_bucket.silver_layer.id
}

output "silver_layer_bucket_arn" {
  description = "The ARN of the S3 bucket for the Silver layer"
  value       = aws_s3_bucket.silver_layer.arn
}

output "silver_layer_bucket_policy_arn" {
  description = "The ARN of the policy for the Silver layer S3 bucket"
  value       = aws_s3_bucket_policy.silver_layer_policy.arn
}


output "bronze_layer_bucket" {
  description = "The name of the S3 bucket for the Bronze layer"
  value       = aws_s3_bucket.bronze_layer.id
}

output "bronze_layer_bucket_arn" {
  description = "The ARN of the S3 bucket for the Bronze layer"
  value       = aws_s3_bucket.bronze_layer.arn
}

output "bronze_layer_bucket_policy_arn" {
  description = "The ARN of the policy for the Bronze layer S3 bucket"
  value       = aws_s3_bucket_policy.bronze_layer_policy.arn
}

output "terraform_state_bucket_name" {
  description = "The name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}


output "terraform_state_bucket_arn" {
  description = "The ARN of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_lock_table_name" {
  description = "The name of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "glue_database_name" {
  description = "The name of the Glue catalog database"
  value       = aws_glue_catalog_database.btc_usd_db.name
}

output "ecs_execution_role_arn" {
  description = "The ARN of the IAM role for ECS execution"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the IAM role for ECS tasks"
  value       = aws_iam_role.ecs_task_role.arn
}

output "emr_service_role_arn" {
  description = "The ARN of the IAM role for EMR service"
  value       = aws_iam_role.emr_service_role.arn
}

output "glue_role_arn" {
  description = "The ARN of the IAM role for Glue"
  value       = aws_iam_role.glue_role.arn
}

output "terraform_state_lock_table_arn" {
  description = "The ARN of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}

output "glue_job_name" {
  description = "The name of the Glue job"
  value       = aws_glue_job.btc_usd_job.name
}

output "glue_crawler_name" {
  description = "The name of the Glue crawler"
  value       = aws_glue_crawler.btc_usd_crawler.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.private.id
}