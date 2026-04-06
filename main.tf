# Підключаємо модуль для S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"          # Шлях до модуля
  bucket_name = "tf-state-mrutkovskyi-lesson89" # Ім'я S3-бакета
  table_name  = "terraform-locks"               # Ім'я DynamoDB
}

# Підключаємо модуль для VPC
module "vpc" {
  source             = "./modules/vpc"                                     # Шлях до модуля VPC
  vpc_cidr_block     = "10.0.0.0/16"                                       # CIDR блок для VPC
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]       # Публічні підмережі
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]       # Приватні підмережі
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"] # Зони доступності
  vpc_name           = "vpc"                                               # Ім'я VPC
  cluster_name       = "eks-cluster-demo"                                  # Назва EKS-кластера для тегів підмереж
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "django-app"
  scan_on_push = true
}

# Підключаємо модуль EKS
module "eks" {
  source          = "./modules/eks"
  cluster_name    = "eks-cluster-demo"                                            # Назва кластера
  subnet_ids      = concat(module.vpc.public_subnets, module.vpc.private_subnets) # Підмережі для контрольної площини
  node_subnet_ids = module.vpc.private_subnets                                    # Worker nodes — в приватних підмережах
  instance_type   = "t3.small"                                                    # Тип інстансів (Jenkins+ArgoCD потребують більше ресурсів)
  desired_size    = 2                                                             # Бажана кількість нодів
  max_size        = 3                                                             # Максимальна кількість нодів
  min_size        = 1                                                             # Мінімальна кількість нодів
}

# Підключаємо модуль RDS
module "rds" {
  source = "./modules/rds"

  identifier     = "app-database"
  use_aurora     = false
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = "db.t3.micro"

  db_name     = "appdb"
  db_username = "dbadmin"
  db_password = "ChangeMe123!"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_cidr_blocks = ["10.0.0.0/16"]

  tags = {
    Environment = "dev"
    Project     = "terraform-lesson"
  }
}

# Підключаємо модуль Jenkins
module "jenkins" {
  source = "./modules/jenkins"

  depends_on = [module.eks]
}

# Підключаємо модуль Argo CD
module "argo_cd" {
  source = "./modules/argo_cd"

  git_repo_url        = "https://github.com/Etyamor/terraform-lesson-4.git"
  git_target_revision = "main"
  app_chart_path      = "charts/django-app"

  depends_on = [module.eks]
}
