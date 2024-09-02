variable "ecs_execution_role_name" {
  description = "The name of the IAM role for ECS execution"
  default     = "ecs_execution_role"
}

variable "ecs_task_role_name" {
  description = "The name of the IAM role for ECS tasks"
  default     = "ecs_task_role"
}

variable "emr_service_role_name" {
  description = "The name of the IAM role for EMR service"
  default     = "emr_service_role"
}

variable "glue_role_name" {
  description = "The name of the IAM role for Glue service"
  default     = "glue_role"
}

variable "msk_connect_role_name" {
  description = "The name of the IAM role for MSK Connect"
  default     = "msk_connect_role"
}

variable "ecs_task_policy_name" {
  description = "The name of the IAM policy for ECS tasks"
  default     = "ecs_task_policy"
}

variable "msk_connect_policy_name" {
  description = "The name of the IAM policy for MSK Connect"
  default     = "msk_connect_policy"
}

variable "emr_policy_name" {
  description = "The name of the IAM policy for EMR"
  default     = "emr_policy"
}

variable "glue_policy_name" {
  description = "The name of the IAM policy for Glue"
  default     = "glue_policy"
}
