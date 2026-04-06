# Terraform RDS Module

Universal Terraform module that creates either a regular RDS instance or an Aurora cluster, controlled by a single `use_aurora` flag.

## Project Structure

```
modules/rds/
  rds.tf          # Regular RDS instance (use_aurora = false)
  aurora.tf       # Aurora cluster + instances (use_aurora = true)
  shared.tf       # DB Subnet Group, Security Group, Parameter Groups
  variables.tf    # Input variables with types, descriptions, defaults
  outputs.tf      # Module outputs
```

## Usage

### Regular RDS (PostgreSQL)

```hcl
module "rds" {
  source = "./modules/rds"

  identifier     = "app-database"
  use_aurora     = false
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = "db.t3.micro"

  db_name     = "appdb"
  db_username = "dbadmin"
  db_password = var.db_password

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_cidr_blocks = ["10.0.0.0/16"]
}
```

### Aurora Cluster (PostgreSQL)

```hcl
module "rds" {
  source = "./modules/rds"

  identifier     = "app-database"
  use_aurora     = true
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = "db.r6g.large"

  aurora_instance_count = 2

  db_name     = "appdb"
  db_username = "dbadmin"
  db_password = var.db_password

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_cidr_blocks = ["10.0.0.0/16"]
}
```

### MySQL Example

```hcl
module "rds" {
  source = "./modules/rds"

  identifier     = "mysql-database"
  use_aurora     = false
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  db_name     = "appdb"
  db_username = "dbadmin"
  db_password = var.db_password

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}
```

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `use_aurora` | `bool` | `false` | Use Aurora cluster instead of regular RDS instance |
| `engine` | `string` | `"postgres"` | Database engine: `postgres` or `mysql` |
| `engine_version` | `string` | `"16.4"` | Engine version (e.g. `16.4` for PostgreSQL, `8.0` for MySQL) |
| `instance_class` | `string` | `"db.t3.micro"` | Instance class (e.g. `db.t3.micro`, `db.r6g.large` for Aurora) |
| `allocated_storage` | `number` | `20` | Storage in GB (regular RDS only, ignored for Aurora) |
| `db_name` | `string` | `"appdb"` | Database name to create |
| `db_username` | `string` | `"dbadmin"` | Master username |
| `db_password` | `string` | - | Master password (sensitive, required) |
| `multi_az` | `bool` | `false` | Multi-AZ deployment (regular RDS only) |
| `vpc_id` | `string` | - | VPC ID (required) |
| `subnet_ids` | `list(string)` | - | Subnet IDs for DB subnet group (required) |
| `allowed_cidr_blocks` | `list(string)` | `["10.0.0.0/16"]` | CIDR blocks allowed to access DB |
| `identifier` | `string` | `"app-database"` | Resource identifier/name |
| `aurora_instance_count` | `number` | `1` | Number of Aurora instances (writer + readers) |
| `backup_retention_period` | `number` | `7` | Backup retention in days |
| `skip_final_snapshot` | `bool` | `true` | Skip final snapshot on destroy |
| `tags` | `map(string)` | `{}` | Additional tags |

## Outputs

| Output | Description |
|--------|-------------|
| `endpoint` | Database connection endpoint |
| `reader_endpoint` | Aurora reader endpoint (null for regular RDS) |
| `port` | Database port |
| `db_name` | Database name |
| `security_group_id` | Security group ID |
| `subnet_group_name` | DB subnet group name |

## How to change database type

**Switch from RDS to Aurora:**
Set `use_aurora = true` and adjust `instance_class` to an Aurora-compatible class (e.g. `db.r6g.large`).

**Change engine from PostgreSQL to MySQL:**
Set `engine = "mysql"` and `engine_version = "8.0"`.

**Change instance class:**
Set `instance_class` to desired value (e.g. `db.t3.medium`, `db.r6g.xlarge`).

**Enable Multi-AZ for regular RDS:**
Set `multi_az = true` (not applicable for Aurora, which handles HA at the cluster level).

**Scale Aurora readers:**
Increase `aurora_instance_count` (first instance is always the writer).

## Parameter Groups

The module automatically creates parameter groups with the following PostgreSQL parameters:
- `max_connections = 100`
- `log_statement = all`
- `work_mem = 4096` (KB)

For MySQL, only `max_connections` is set (other parameters are PostgreSQL-specific).

The parameter group family is computed automatically based on `engine` and `engine_version`.

## Deploying

```bash
terraform init
terraform apply
```

## Cleanup

```bash
terraform destroy
```
