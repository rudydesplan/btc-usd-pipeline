variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  default     = "btc-usd-cluster"
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository"
  default     = "btc-usd-repo"
}

variable "ecs_execution_role_name" {
  description = "The name of the IAM role for ECS execution"
  default     = "ecs_execution_role"
}

variable "ecs_task_role_name" {
  description = "The name of the IAM role for ECS tasks"
  default     = "ecs_task_role"
}

variable "ecs_task_policy_name" {
  description = "The name of the IAM policy for ECS tasks"
  default     = "ecs_task_policy"
}

variable "ecs_tasks_sg_name" {
  description = "The name of the security group for ECS tasks"
  default     = "ecs-tasks-sg"
}
