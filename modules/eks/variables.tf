variable "cluster_name" {
  description = "Назва EKS-кластера"
  default     = "example-eks-cluster"
}

variable "subnet_ids" {
  description = "Список ID підмереж для контрольної площини EKS"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Список ID підмереж для worker nodes (рекомендовано приватні)"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  default     = 1
}

