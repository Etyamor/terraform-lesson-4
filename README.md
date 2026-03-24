# Terraform Lesson 5

Infrastructure as Code project using Terraform to provision AWS resources including an S3 backend for state management, a VPC with public and private subnets, and an ECR repository for container images.

## Project Structure

```
.
├── main.tf                     # Root module — connects all child modules
├── backend.tf                  # S3 remote backend configuration
├── outputs.tf                  # Root-level outputs
└── modules/
    ├── s3-backend/             # S3 + DynamoDB for Terraform state
    │   ├── s3.tf
    │   ├── dynamodb.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── vpc/                    # VPC with subnets and routing
    │   ├── vpc.tf
    │   ├── routes.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecr/                    # ECR container registry
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Commands

Initialize the project (downloads providers, configures backend):

```bash
terraform init
```

Preview the changes Terraform will make:

```bash
terraform plan
```

Apply the changes to create/update infrastructure:

```bash
terraform apply
```

Destroy all managed infrastructure:

```bash
terraform destroy
```

## Modules

### s3-backend

Creates an S3 bucket with versioning enabled and a DynamoDB table for state locking. This ensures safe concurrent access to the Terraform state file.

- **S3 bucket** — stores `terraform.tfstate` with versioning and `BucketOwnerEnforced` ownership
- **DynamoDB table** — provides state locking via a `LockID` hash key

### vpc

Provisions a VPC with public and private subnets across multiple availability zones.

- **VPC** — `10.0.0.0/16` CIDR block with DNS support and DNS hostnames enabled
- **Public subnets** (3) — auto-assign public IPs, routed to the Internet Gateway
- **Private subnets** (3) — no public IP assignment, isolated from direct internet access
- **Internet Gateway** — provides internet access for public subnets
- **Route table** — routes `0.0.0.0/0` traffic from public subnets through the IGW

### ecr

Creates an Elastic Container Registry repository for storing Docker images.

- **ECR repository** — named `lesson-5-ecr`, with image scanning on push enabled
- **Image tag mutability** — set to `MUTABLE` (tags can be overwritten)
