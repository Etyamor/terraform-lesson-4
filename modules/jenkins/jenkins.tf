# Створюємо namespace для Jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

# Встановлюємо Jenkins через Helm
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    templatefile("${path.module}/values.yaml", {
      admin_password = var.admin_password
    })
  ]

  timeout = 600
}
