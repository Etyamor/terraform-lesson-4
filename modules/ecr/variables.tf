variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Сканування образів при завантаженні"
  type        = bool
  default     = true
}
