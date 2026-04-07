variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "67.9.0"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin"
  sensitive   = true
}
