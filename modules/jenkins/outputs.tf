output "jenkins_namespace" {
  description = "Namespace де встановлений Jenkins"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "jenkins_admin_password" {
  description = "Пароль адміністратора Jenkins"
  value       = var.admin_password
  sensitive   = true
}
