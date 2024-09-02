# AWS Region
aws_region = "eu-north-1"

# Project Name
project_name = "btc-usd-pipeline"

# Terraform State Management
terraform_state_bucket = "terraform-state-bucket"
terraform_state_lock_table = "terraform-state-lock-table"

# API Keys and Credentials
finnhub_api_key = "<TO_BE_SET_VIA_ENVIRONMENT>"
msk_username = "<TO_BE_SET_VIA_ENVIRONMENT>"
msk_password = "<TO_BE_SET_VIA_ENVIRONMENT>"

# Kafka Configuration
kafka_topic = "btc-usd-topic"

# Network Configuration
vpc_cidr = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"

# You can add more variables here as needed, such as:
# ecs_task_cpu = "256"
# ecs_task_memory = "512"
# msk_instance_type = "kafka.t3.small"
# emr_master_instance_type = "m4.large"
# emr_core_instance_type = "m4.large"
# emr_core_instance_count = 1
