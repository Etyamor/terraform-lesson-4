# Створюємо основну VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block # CIDR блок для нашої VPC (наприклад, 10.0.0.0/16)
  enable_dns_support   = true               # Вмикає підтримку DNS у VPC
  enable_dns_hostnames = true               # Вмикає можливість використання DNS-імен для ресурсів у VPC

  tags = {
    Name = "${var.vpc_name}-vpc" # Додаємо тег, який включає ім'я VPC
  }
}

# Створюємо публічні підмережі
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)          # Створюємо кілька підмереж, кількість визначена довжиною списку public_subnets
  vpc_id                  = aws_vpc.main.id                     # Прив'язуємо кожну підмережу до VPC, створеної раніше
  cidr_block              = var.public_subnets[count.index]     # CIDR-блок для конкретної підмережі зі списку public_subnets
  availability_zone       = var.availability_zones[count.index] # Визначаємо зони доступності для кожної підмережі
  map_public_ip_on_launch = true                                # Автоматично надає публічні IP-адреси інстансам у підмережі

  tags = {
    Name                                        = "${var.vpc_name}-public-subnet-${count.index + 1}" # Тег з нумерацією підмережі
    "kubernetes.io/role/elb"                    = "1"                                                # Тег для EKS — дозволяє створювати зовнішні Load Balancer
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"                                           # Тег для EKS — підмережа належить кластеру
  }
}

# Створюємо приватні підмережі
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)         # Створюємо кілька приватних підмереж, кількість відповідає довжині списку private_subnets
  vpc_id            = aws_vpc.main.id                     # Прив'язуємо кожну приватну підмережу до VPC
  cidr_block        = var.private_subnets[count.index]    # CIDR-блок для конкретної підмережі зі списку private_subnets
  availability_zone = var.availability_zones[count.index] # Визначаємо зони доступності для підмереж

  tags = {
    Name                                        = "${var.vpc_name}-private-subnet-${count.index + 1}" # Тег для підмережі з нумерацією
    "kubernetes.io/role/internal-elb"           = "1"                                                 # Тег для EKS — дозволяє створювати внутрішні Load Balancer
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"                                            # Тег для EKS — підмережа належить кластеру
  }
}

# Створюємо Internet Gateway для публічних підмереж
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id # Прив'язуємо Internet Gateway до VPC для виходу в інтернет

  tags = {
    Name = "${var.vpc_name}-igw" # Тег для ідентифікації Internet Gateway
  }
}

