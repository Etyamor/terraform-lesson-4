# IAM-роль для EKS-кластера
resource "aws_iam_role" "eks" {
  # Ім'я IAM-ролі для кластера EKS
  name = "${var.cluster_name}-eks-cluster"

  # Політика, яка дозволяє сервісу EKS «асумувати» цю IAM-роль
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# Прив'язка IAM-ролі до політики AmazonEKSClusterPolicy
resource "aws_iam_role_policy_attachment" "eks" {
  # ARN політики, що надає дозволи для EKS-кластера
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  # IAM-роль, до якої прив'язується політика
  role = aws_iam_role.eks.name
}

# Створення EKS-кластера
resource "aws_eks_cluster" "eks" {
  # Назва кластера
  name = var.cluster_name

  # ARN IAM-ролі, яка потрібна для керування кластером
  role_arn = aws_iam_role.eks.arn

  # Налаштування мережі (VPC)
  vpc_config {
    endpoint_private_access = true           # Включає приватний доступ до API-сервера
    endpoint_public_access  = true           # Включає публічний доступ до API-сервера
    subnet_ids              = var.subnet_ids # Список підмереж, де буде працювати EKS
  }

  # Налаштування доступу до EKS-кластера
  access_config {
    authentication_mode                         = "API" # Автентифікація через API
    bootstrap_cluster_creator_admin_permissions = true  # Надає адміністративні права користувачу, який створив кластер
  }

  # Залежність від IAM-політики для ролі EKS
  depends_on = [aws_iam_role_policy_attachment.eks]
}

# IAM-роль для EC2-вузлів (Worker Nodes)
resource "aws_iam_role" "nodes" {
  # Ім'я ролі для вузлів
  name = "${var.cluster_name}-eks-nodes"

  # Політика, що дозволяє EC2 асумувати роль
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# Прив'язка політики для EKS Worker Nodes
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# Прив'язка політики для Amazon VPC CNI плагіну
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# Прив'язка політики для читання з Amazon ECR
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Створення Node Group для EKS
resource "aws_eks_node_group" "general" {
  # Ім'я EKS-кластера
  cluster_name = aws_eks_cluster.eks.name

  # Ім'я групи вузлів
  node_group_name = "general"

  # IAM-роль для вузлів
  node_role_arn = aws_iam_role.nodes.arn

  # Підмережі, де будуть EC2-вузли (приватні підмережі)
  subnet_ids = var.node_subnet_ids

  # Тип EC2-інстансів для вузлів
  capacity_type  = "ON_DEMAND"
  instance_types = [var.instance_type]

  # Конфігурація масштабування
  scaling_config {
    desired_size = var.desired_size # Бажана кількість вузлів
    max_size     = var.max_size     # Максимальна кількість вузлів
    min_size     = var.min_size     # Мінімальна кількість вузлів
  }

  # Конфігурація оновлення вузлів
  update_config {
    max_unavailable = 1 # Максимальна кількість вузлів, які можна оновлювати одночасно
  }

  # Додає мітки до вузлів
  labels = {
    role = "general" # Тег "role" зі значенням "general"
  }

  # Залежності для створення Node Group
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  # Ігнорує зміни в desired_size, щоб уникнути конфліктів
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
