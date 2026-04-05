variable "namespace" {
  description = "Kubernetes namespace для Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Версія Helm chart для Jenkins"
  type        = string
  default     = "5.8.3"
}

variable "admin_password" {
  description = "Пароль адміністратора Jenkins"
  type        = string
  default     = "admin"
  sensitive   = true
}
