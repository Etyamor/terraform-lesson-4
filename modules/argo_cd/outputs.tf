output "argocd_namespace" {
  description = "Namespace де встановлений Argo CD"
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}
