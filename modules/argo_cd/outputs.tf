output "argocd_namespace" {
  description = "Namespace де встановлений Argo CD"
  value       = kubernetes_namespace.argocd.metadata[0].name
}
