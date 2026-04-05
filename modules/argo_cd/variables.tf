variable "namespace" {
  description = "Kubernetes namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Версія Helm chart для Argo CD"
  type        = string
  default     = "7.8.13"
}

variable "git_repo_url" {
  description = "URL Git-репозиторію з Helm-чартом Django"
  type        = string
}

variable "git_target_revision" {
  description = "Git branch або tag для відстеження"
  type        = string
  default     = "main"
}

variable "app_chart_path" {
  description = "Шлях до Helm chart в репозиторії"
  type        = string
  default     = "charts/django-app"
}

variable "app_namespace" {
  description = "Namespace для деплою Django-застосунку"
  type        = string
  default     = "default"
}
