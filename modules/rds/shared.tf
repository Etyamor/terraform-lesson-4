locals {
  # Aurora engine mapping
  aurora_engine = var.engine == "postgres" ? "aurora-postgresql" : "aurora-mysql"

  # Parameter group family computation
  version_parts        = split(".", var.engine_version)
  engine_major_version = local.version_parts[0]
  engine_major_minor   = "${local.version_parts[0]}.${length(local.version_parts) > 1 ? local.version_parts[1] : "0"}"

  # PostgreSQL uses major version only (postgres16), MySQL uses major.minor (mysql8.0)
  rds_family    = var.engine == "postgres" ? "postgres${local.engine_major_version}" : "mysql${local.engine_major_minor}"
  aurora_family = var.engine == "postgres" ? "aurora-postgresql${local.engine_major_version}" : "aurora-mysql${local.engine_major_minor}"

  # Database port
  db_port = var.engine == "postgres" ? 5432 : 3306

  # Parameters based on engine type
  is_postgres = var.engine == "postgres"

  db_parameters = local.is_postgres ? [
    { name = "max_connections", value = "100" },
    { name = "log_statement", value = "ddl" },
    { name = "work_mem", value = "4096" },
  ] : [
    { name = "max_connections", value = "100" },
  ]
}

# ----- DB Subnet Group (shared) -----

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# ----- Security Group (shared) -----

resource "aws_security_group" "this" {
  name        = "${var.identifier}-sg"
  description = "Security group for ${var.identifier} database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-sg"
  })
}

# ----- Parameter Group for regular RDS -----

resource "aws_db_parameter_group" "this" {
  count = var.use_aurora ? 0 : 1

  name   = "${var.identifier}-params"
  family = local.rds_family

  dynamic "parameter" {
    for_each = local.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-params"
  })
}

# ----- Parameter Group for Aurora cluster -----

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.identifier}-cluster-params"
  family = local.aurora_family

  dynamic "parameter" {
    for_each = local.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-cluster-params"
  })
}
