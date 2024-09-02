variable "emr_cluster_name" {
  description = "The name of the EMR cluster"
  default     = "btc-usd-emr-cluster"
}

variable "emr_release_label" {
  description = "The EMR release label"
  default     = "emr-7.2.0"
}

variable "emr_applications" {
  description = "The list of applications to install on the EMR cluster"
  type        = list(string)
  default     = ["Spark"]
}

variable "emr_master_instance_type" {
  description = "The instance type for the EMR master node"
  default     = "m4.large"
}

variable "emr_core_instance_type" {
  description = "The instance type for the EMR core nodes"
  default     = "m4.large"
}

variable "emr_core_instance_count" {
  description = "The number of instances in the EMR core node group"
  default     = 1
}

variable "emr_instance_profile_name" {
  description = "The name of the IAM instance profile for the EMR cluster"
  default     = "emr_profile"
}

variable "emr_ec2_instance_role_name" {
  description = "The name of the IAM role for the EMR EC2 instances"
  default     = "emr_ec2_instance_profile"
}

variable "emr_sg_name" {
  description = "The name of the security group for the EMR cluster"
  default     = "emr-sg"
}