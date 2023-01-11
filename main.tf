
# VPC
resource "aws_vpc" "my_vpc_01" {
  tags = {
    Name = "my-vpc-01"
  }

  tags_all = {
    Name = "my-vpc-01"
  }

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
}


# Subnet
resource "aws_subnet" "private_subnet" {
  tags = {
    Name = "private-subnet"
  }

  tags_all = {
    Name = "private-subnet"
  }

  availability_zone_id                = "use1-az4"
  cidr_block                          = "10.0.2.0/24"
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = aws_vpc.my_vpc_01.id
}

resource "aws_subnet" "public_subnet" {
  tags = {
    Name = "public-subnet"
  }

  tags_all = {
    Name = "public-subnet"
  }

  availability_zone_id                = "use1-az2"
  cidr_block                          = "10.0.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = aws_vpc.my_vpc_01.id
}

resource "aws_internet_gateway" "app_internet_gateway" {
  tags = {
    Name = "app-internet-gateway"
  }

  tags_all = {
    Name = "app-internet-gateway"
  }

  vpc_id = aws_vpc.my_vpc_01.id
}



# Route Table
resource "aws_route_table" "private_route_table" {
  tags = {
    Name = "private-route-table"
  }

  tags_all = {
    Name = "private-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_internet_gateway.id
  }

  vpc_id = aws_vpc.my_vpc_01.id
}

resource "aws_route_table" "public_route_table" {
  tags = {
    Name = "public-route-table"
  }

  tags_all = {
    Name = "public-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_internet_gateway.id
  }

  vpc_id = aws_vpc.my_vpc_01.id
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}



# Security Group
resource "aws_security_group" "api_security_group" {
  name        = "api-security-group"
  description = "api security group"
  vpc_id      = aws_vpc.my_vpc_01.id

  tags = {
    Name = "api-security-group"

  }
}




# security_groups        = ["APISecurityGroup"]
#   source_dest_check      = true
#   subnet_id              = aws_subnet..subnet_0873c8968c11935e2.id
#   tenancy                = aws_vpc.vpc_0eed75d9570db478e.instance_tenancy
#   vpc_security_group_ids = [aws_security_group.api_security_group.id]

/*
# RDS
resource "aws_db_instance" "stage" {
  identifier_prefix    = "stage-up-and-running"
  engine               = "mysql"
  allocated_storage    = 10
  instance_class       = "db.t2.micro"
  skip_final_snapshot  = true
  db_name              = "stage_database"
  db_subnet_group_name = "default"
  username             = var.db_username
  password             = var.db_password

  auto_minor_version_upgrade = true
  backup_window              = "04:19-04:49"
  ca_cert_identifier         = "rds-ca-2019"
  copy_tags_to_snapshot      = true
}

  db_subnet_group_name       = aws_db_subnet_group.rds_db_sbntg.id
  delete_automated_backups   = true
  engine                     = "mysql"
  engine_version             = "8.0.31"
  identifier                 = "test-db-1"
  instance_class             = "db.t2.micro"
  kms_key_id                 = "arn:aws:kms:us-east-1:391551845951:key/28442241-8bdd-40a4-9584-ca15139ed2c4"
  license_model              = "general-public-license"
  maintenance_window         = "tue:09:30-tue:10:00"
  option_group_name          = "default:mysql-8-0"
  parameter_group_name       = aws_db_parameter_group.default_mysql8_0.id
  port                       = 3306
  skip_final_snapshot        = true
  storage_encrypted          = true
  storage_type               = "gp2"
  username                   = "admin"
  vpc_security_group_ids     = [aws_security_group.rds_db_security_group.id]
}

resource "aws_db_parameter_group" "default_mysql8_0" {
  description = "Default parameter group for mysql8.0"
  family      = "mysql8.0"
  name        = "default.mysql8.0"
}

resource "aws_db_subnet_group" "rds_db_sbntg" {
  description = "for RDS database testing"
  name        = "rds-db-sbntg"
  subnet_ids  = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id]
}

# Route 53
resource "aws_route53_resolver_rule_association" "rslvr_autodefined_assoc_vpc_00cbf222986291997_internet_resolver" {
  name             = "System Rule Association"
  resolver_rule_id = "rslvr-autodefined-rr-internet-resolver"
  vpc_id           = aws_vpc.my_vpc_01.id
}
*/
