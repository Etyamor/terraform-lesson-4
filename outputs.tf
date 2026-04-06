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
