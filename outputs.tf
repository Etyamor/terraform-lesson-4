output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = module.ecr.repository_url
}

output "rds_endpoint" {
  description = "RDS/Aurora database endpoint"
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "RDS/Aurora database port"
  value       = module.rds.port
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = module.jenkins.jenkins_namespace
}

output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = module.argo_cd.argocd_namespace
}

output "monitoring_namespace" {
  description = "Monitoring namespace (Prometheus + Grafana)"
  value       = module.monitoring.monitoring_namespace
}

# --- Service access URLs (via port-forward) ---

output "jenkins_url" {
  description = "Jenkins URL (after port-forward: kubectl port-forward svc/jenkins 8080:8080 -n jenkins)"
  value       = "http://localhost:8080"
}

output "argocd_url" {
  description = "Argo CD URL (after port-forward: kubectl port-forward svc/argocd-server 8081:443 -n argocd)"
  value       = "http://localhost:8081"
}

output "grafana_url" {
  description = "Grafana URL (after port-forward: kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring)"
  value       = "http://localhost:3000"
}

output "prometheus_url" {
  description = "Prometheus URL (after port-forward: kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring)"
  value       = "http://localhost:9090"
}

output "django_app_url" {
  description = "Django app URL (after port-forward: kubectl port-forward svc/django-app-service 8000:80 -n default)"
  value       = "http://localhost:8000"
}
