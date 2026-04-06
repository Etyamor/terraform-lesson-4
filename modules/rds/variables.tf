variable "use_aurora" {
  description = "Use Aurora cluster instead of regular RDS instance"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Database engine: postgres or mysql"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Engine must be 'postgres' or 'mysql'."
  }
}

variable "engine_version" {
  description = "Database engine version (e.g. 16.4 for PostgreSQL, 8.0 for MySQL)"
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "RDS instance class (e.g. db.t3.micro, db.r6g.large)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB (regular RDS only, ignored for Aurora)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment (regular RDS only)"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID where the database will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "identifier" {
  description = "Identifier for the RDS instance or Aurora cluster"
  type        = string
  default     = "app-database"
}

variable "aurora_instance_count" {
  description = "Number of Aurora instances (writer + readers)"
  type        = number
  default     = 1
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying the database"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
