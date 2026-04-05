# Lesson 8-9 — CI/CD: Jenkins + ArgoCD + Helm + Terraform

Повний CI/CD pipeline для Django-застосунку на AWS EKS: Jenkins збирає образ та пушить у ECR, ArgoCD автоматично синхронізує зміни з Git у кластер.

## CI/CD схема

```
Developer -> Git Push -> Jenkins Pipeline -> Build (Kaniko) -> Push to ECR
                                          -> Update values.yaml -> Git Push
                                                                -> ArgoCD Sync -> EKS Cluster
```

## Структура проєкту

```
├── main.tf                     # Головний файл модулів
├── providers.tf                # AWS, Kubernetes, Helm провайдери
├── backend.tf                  # S3 + DynamoDB бекенд
├── outputs.tf                  # Виводи ресурсів
├── Jenkinsfile                 # CI/CD pipeline
├── modules/
│   ├── s3-backend/             # S3 + DynamoDB для Terraform state
│   ├── vpc/                    # VPC (підмережі, NAT Gateway, маршрути)
│   ├── ecr/                    # ECR (реєстр Docker-образів)
│   ├── eks/                    # EKS (кластер + Node Group + EBS CSI Driver)
│   │   ├── eks.tf
│   │   ├── aws_ebs_csi_driver.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── jenkins/                # Jenkins через Helm
│   │   ├── jenkins.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── values.yaml
│   │   └── outputs.tf
│   └── argo_cd/                # Argo CD через Helm
│       ├── argocd.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── values.yaml
│       ├── outputs.tf
│       └── charts/             # App-of-apps chart
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
├── charts/
│   └── django-app/             # Helm chart Django-застосунку
└── django-app/                 # Django-проєкт + Dockerfile
```

## Передумови

- AWS CLI (`aws configure`)
- Terraform >= 1.0
- kubectl
- Helm >= 3.0
- Docker

## 1. Розгортання інфраструктури

Закоментуйте backend блок у `backend.tf`, потім:

```bash
terraform init
terraform apply -target=module.s3_backend
```

Розкоментуйте backend блок, мігруйте стейт:

```bash
terraform init -migrate-state
```

Розгорніть всю інфраструктуру:

```bash
terraform apply
```

Terraform створить: VPC, EKS кластер (2x t3.small), ECR, EBS CSI Driver, Jenkins, Argo CD.

## 2. Налаштування kubectl

```bash
aws eks update-kubeconfig --name eks-cluster-demo --region eu-central-1
kubectl get nodes
```

## 3. Доступ до Jenkins

Отримайте URL Jenkins:

```bash
kubectl get svc -n jenkins jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Логін: `admin`, пароль: `admin` (або значення зі змінної `admin_password`).

### Налаштування Jenkins credentials

В Jenkins UI (Manage Jenkins -> Credentials) додайте:

1. **aws-account-id** (Secret text) — ваш AWS Account ID
2. **github-token** (Username with password) — GitHub username + Personal Access Token

### Створення Jenkins Job

1. New Item -> Pipeline
2. Pipeline Definition: Pipeline script from SCM
3. SCM: Git, URL: `https://github.com/Etyamor/terraform-lesson-4.git`
4. Branch: `*/main`
5. Script Path: `Jenkinsfile`

### Запуск та перевірка

```bash
# Запустіть Build в Jenkins UI або через CLI
# Pipeline збере образ, запушить в ECR та оновить values.yaml
```

## 4. Доступ до Argo CD

Отримайте URL Argo CD:

```bash
kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Отримайте початковий пароль:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Логін: `admin`.

### Перевірка синхронізації

В Argo CD UI перевірте Application `django-app`:
- Status: Synced
- Health: Healthy

Або через CLI:

```bash
kubectl get applications -n argocd
```

## 5. Як працює CI/CD

1. **Jenkins Pipeline** запускається (вручну або по webhook)
2. **Kaniko** збирає Docker-образ з `django-app/Dockerfile`
3. Образ пушиться в **ECR** з тегом = номер білду
4. Pipeline оновлює `tag` у `charts/django-app/values.yaml` і пушить в Git
5. **Argo CD** виявляє зміну в Git і автоматично синхронізує кластер

## Модулі Terraform

| Модуль | Опис |
|--------|------|
| **s3-backend** | S3 + DynamoDB для Terraform state |
| **vpc** | VPC з 3 публічними та 3 приватними підмережами, NAT Gateway |
| **ecr** | ECR-репозиторій `django-app` |
| **eks** | EKS-кластер з Node Group + EBS CSI Driver (для Jenkins PV) |
| **jenkins** | Jenkins через Helm з Kubernetes agent (Kaniko + Git) |
| **argo_cd** | Argo CD через Helm + Application для django-app |

## Очистка ресурсів

```bash
terraform destroy
```
