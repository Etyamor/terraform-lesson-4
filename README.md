# Lesson 7 — Kubernetes (EKS) + Helm + ECR

Проєкт розгортає Django-застосунок у кластері Amazon EKS з використанням Terraform та Helm.

## Структура проєкту

```
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # S3 + DynamoDB бекенд для стейтів
├── outputs.tf               # Виводи ресурсів
├── modules/
│   ├── s3-backend/          # Модуль S3 та DynamoDB для Terraform state
│   ├── vpc/                 # Модуль VPC (підмережі, NAT Gateway, маршрути)
│   ├── ecr/                 # Модуль ECR (реєстр Docker-образів)
│   └── eks/                 # Модуль EKS (Kubernetes-кластер + Node Group)
└── charts/
    └── django-app/          # Helm chart для Django-застосунку
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            └── hpa.yaml
```

## Передумови

- AWS CLI налаштований (`aws configure`)
- Terraform >= 1.0
- kubectl
- Helm >= 3.0
- Docker

## 1. Розгортання інфраструктури через Terraform

```bash
terraform init
terraform plan
terraform apply
```

Terraform створить:
- **VPC** з публічними та приватними підмережами у 3 AZ
- **NAT Gateway** для доступу приватних підмереж до інтернету
- **EKS-кластер** з Node Group у приватних підмережах
- **ECR-репозиторій** для зберігання Docker-образів

## 2. Налаштування kubectl

```bash
aws eks update-kubeconfig --name eks-cluster-demo --region us-west-2
```

Перевірка підключення:

```bash
kubectl get nodes
```

## 3. Завантаження Docker-образу до ECR

Авторизація в ECR:

```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
```

Збірка та завантаження образу:

```bash
docker build -t django-app .
docker tag django-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/django-app:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/django-app:latest
```

## 4. Деплой застосунку через Helm

Перед встановленням відредагуйте `charts/django-app/values.yaml` — замініть `<AWS_ACCOUNT_ID>` на реальний ID акаунту.

```bash
helm install django-app ./charts/django-app
```

Перевірка статусу:

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl get configmap
```

## 5. Доступ до застосунку

Отримайте зовнішню адресу LoadBalancer:

```bash
kubectl get svc django-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Модулі Terraform

### s3-backend

S3-бакет з версіонуванням та DynamoDB-таблиця для блокування стейтів.

### vpc

VPC `10.0.0.0/16` з 3 публічними та 3 приватними підмережами у різних AZ. Internet Gateway для публічних підмереж, NAT Gateway для приватних. Підмережі тегуються для автоматичного виявлення EKS.

### ecr

ECR-репозиторій `django-app` зі скануванням образів при завантаженні та політикою доступу.

### eks

EKS-кластер `eks-cluster-demo` з Node Group у приватних підмережах. IAM-ролі для кластера та worker nodes з необхідними політиками.

## Компоненти Helm chart

| Ресурс | Опис |
|--------|------|
| **Deployment** | Розгортає Django-контейнер з образом з ECR, підключає ConfigMap через envFrom |
| **Service** | LoadBalancer для зовнішнього доступу на порт 80 -> 8000 |
| **ConfigMap** | Змінні середовища Django (DEBUG, ALLOWED_HOSTS, DATABASE_ENGINE тощо) |
| **HPA** | Автоскейлінг від 2 до 6 подів при CPU > 70% |

## Очистка ресурсів

```bash
helm uninstall django-app
terraform destroy
```
