resource "aws_db_instance" "testdb" {
  allocated_storage                     = 20
  auto_minor_version_upgrade            = true
  availability_zone                     = "us-east-1c"
  backup_window                         = "04:56-05:26"
  ca_cert_identifier                    = "rds-ca-2019"
  copy_tags_to_snapshot                 = true
  db_name                               = "testdb"
  db_subnet_group_name                  = "default"
  delete_automated_backups              = true
  engine                                = "postgres"
  engine_version                        = "14.5"
  identifier                            = "testdb"
  instance_class                        = "db.t3.micro"
  kms_key_id                            = "arn:aws:kms:us-east-1:391551845951:key/28442241-8bdd-40a4-9584-ca15139ed2c4"
  license_model                         = "postgresql-license"
  maintenance_window                    = "thu:10:00-thu:10:30"
  monitoring_interval                   = 60
  monitoring_role_arn                   = "arn:aws:iam::391551845951:role/rds-monitoring-role"
  option_group_name                     = "default:postgres-14"
  parameter_group_name                  = "default.postgres14"
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = "arn:aws:kms:us-east-1:391551845951:key/28442241-8bdd-40a4-9584-ca15139ed2c4"
  performance_insights_retention_period = 7
  port                                  = 5432
  publicly_accessible                   = true
  skip_final_snapshot                   = true
  storage_encrypted                     = true
  storage_type                          = "gp2"
  username                              = "dbuser"
  vpc_security_group_ids                = ["sg-010baad65060fe539"]
}

