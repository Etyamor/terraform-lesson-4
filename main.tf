# Підключаємо модуль для S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"          # Шлях до модуля
  bucket_name = "terraform-state-bucket-001001" # Ім'я S3-бакета
  table_name  = "terraform-locks"               # Ім'я DynamoDB
}

# Підключаємо модуль для VPC
module "vpc" {
  source             = "./modules/vpc"                               # Шлях до модуля VPC
  vpc_cidr_block     = "10.0.0.0/16"                                 # CIDR блок для VPC
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # Публічні підмережі
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"] # Приватні підмережі
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]    # Зони доступності
  vpc_name           = "vpc"                                         # Ім'я VPC
  cluster_name       = "eks-cluster-demo"                            # Назва EKS-кластера для тегів підмереж
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
  instance_type   = "t2.micro"                                                    # Тип інстансів
  desired_size    = 1                                                             # Бажана кількість нодів
  max_size        = 2                                                             # Максимальна кількість нодів
  min_size        = 1                                                             # Мінімальна кількість нодів
}