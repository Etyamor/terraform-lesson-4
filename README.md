# Final Project — AWS Infrastructure with Terraform

Django application deployed on AWS EKS with CI/CD (Jenkins + Argo CD), monitoring (Prometheus + Grafana), and RDS database.

## Architecture

```
AWS eu-central-1
├── VPC (10.0.0.0/16)
│   ├── Public subnets (3 AZ) + IGW + NAT Gateway
│   └── Private subnets (3 AZ)
├── EKS Cluster (eks-cluster-demo)
│   ├── jenkins        namespace — CI/CD
│   ├── argocd         namespace — GitOps
│   ├── monitoring     namespace — Prometheus + Grafana
│   └── default        namespace — Django app
├── ECR (django-app) — Docker registry
├── RDS PostgreSQL 16.4 (private subnets)
└── S3 + DynamoDB — Terraform state backend
```

## Project Structure

```
├── main.tf              # Root module — connects all modules
├── backend.tf           # S3 + DynamoDB state backend
├── providers.tf         # AWS, Kubernetes, Helm providers
├── variables.tf         # Root variables (db_password)
├── outputs.tf           # All outputs and service URLs
├── Jenkinsfile          # CI/CD pipeline (Kaniko + Git)
│
├── modules/
│   ├── s3-backend/      # S3 bucket + DynamoDB for state
│   ├── vpc/             # VPC, subnets, IGW, NAT
│   ├── ecr/             # Elastic Container Registry
│   ├── eks/             # EKS cluster + EBS CSI driver
│   ├── rds/             # RDS/Aurora (universal module)
│   ├── jenkins/         # Jenkins via Helm
│   ├── argo_cd/         # Argo CD via Helm + app-of-apps
│   └── monitoring/      # Prometheus + Grafana (kube-prometheus-stack)
│
├── charts/django-app/   # Helm chart for Django app
└── django-app/          # Django source code + Dockerfile
```

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- kubectl
- Helm 3

## Deployment

### Step 1 — Create state backend first

Comment out the `backend "s3"` block in `backend.tf`, then:

```bash
terraform init
terraform apply -target=module.s3_backend
```

Uncomment `backend "s3"` in `backend.tf`, then migrate state:

```bash
terraform init -migrate-state
```

### Step 2 — Create terraform.tfvars

```bash
cat > terraform.tfvars <<'EOF'
db_password = "YourSecurePassword123!"
EOF
```

This file is in `.gitignore` and will not be committed.

### Step 3 — Deploy all infrastructure

```bash
terraform apply
```

This creates: VPC, EKS, ECR, RDS, Jenkins, Argo CD, Prometheus, Grafana.

### Step 4 — Configure kubectl

```bash
aws eks update-kubeconfig --name eks-cluster-demo --region eu-central-1
```

### Step 5 — Verify resources

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
kubectl get all -n default
```

## Accessing Services

### Jenkins

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Open: http://localhost:8080
- Login: `admin`
- Password: `admin` (or get from secret: `kubectl get secret jenkins -n jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d`)

### Argo CD

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

Open: http://localhost:8081
- Login: `admin`
- Password: `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d`

### Grafana

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
```

Open: http://localhost:3000
- Login: `admin`
- Password: `admin`

### Prometheus

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring
```

Open: http://localhost:9090

### Django Application

```bash
kubectl port-forward svc/django-app-service 8000:80 -n default
```

Open: http://localhost:8000

## CI/CD Pipeline

1. **Jenkins** builds Docker image with Kaniko and pushes to ECR
2. **Jenkins** updates `charts/django-app/values.yaml` with new image tag
3. **Argo CD** detects Git changes and syncs the deployment automatically

## Cleanup

```bash
terraform destroy
```

After destroy, the S3 backend is also deleted. On next deploy, start from Step 1.
