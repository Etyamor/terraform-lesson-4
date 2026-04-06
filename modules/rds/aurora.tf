# Aurora cluster (created when use_aurora = true)

resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = var.identifier
  engine             = local.aurora_engine
  engine_version     = var.engine_version

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot

  tags = merge(var.tags, {
    Name = var.identifier
  })
}

# Aurora cluster instances (writer + readers)

resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? var.aurora_instance_count : 0

  identifier         = "${var.identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = local.aurora_engine
  engine_version     = var.engine_version

  tags = merge(var.tags, {
    Name = "${var.identifier}-${count.index}"
  })
}
