# Створюємо namespace для Argo CD
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.namespace
  }
}

# Встановлюємо Argo CD через Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name

  values = [file("${path.module}/values.yaml")]

  timeout = 600
  wait    = false
}

# Встановлюємо ArgoCD Applications через окремий Helm chart (app-of-apps)
resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  set = [
    {
      name  = "application.repoURL"
      value = var.git_repo_url
    },
    {
      name  = "application.targetRevision"
      value = var.git_target_revision
    },
    {
      name  = "application.path"
      value = var.app_chart_path
    },
    {
      name  = "application.namespace"
      value = var.app_namespace
    },
  ]

  depends_on = [helm_release.argocd]
}
