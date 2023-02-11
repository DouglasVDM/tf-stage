
# VPC
resource "aws_vpc" "my_vpc_01" {
  tags = {
    Name = "my-vpc-01"
  }

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  # public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

}


# Subnet
resource "aws_subnet" "private_subnet" {
  tags = {
    Name = "private-subnet"
  }

  availability_zone_id = "use1-az4"
  cidr_block           = "10.0.2.0/24"
  vpc_id               = aws_vpc.my_vpc_01.id
}

resource "aws_subnet" "public_subnet" {
  tags = {
    Name = "public-subnet"
  }

  availability_zone_id    = "use1-az2"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.my_vpc_01.id
}

resource "aws_internet_gateway" "app_internet_gateway" {
  tags = {
    Name = "app-internet-gateway"
  }

  vpc_id = aws_vpc.my_vpc_01.id
}

# Route Table
resource "aws_route_table" "private_route_table" {
  tags = {
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
resource "aws_security_group" "private_sg" {
  tags = {
    Name = "Private Security Group"
  }

  description = "Security Group for Node API and MySql db"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["102.65.62.201/32"]
    description = "Admin Desktop"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "open https web port for internet traffic"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["102.134.74.40/32"]
    description = "Admin Laptop"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "first api listening on this port"
    from_port   = 5001
    protocol    = "tcp"
    to_port     = 5001
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "second api listening on this port"
    from_port   = 5002
    protocol    = "tcp"
    to_port     = 5002
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "open http web port for internet traffic"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  name   = "private-security-group"
  vpc_id = aws_vpc.my_vpc_01.id
}

resource "aws_security_group" "public_sg" {
  tags = {
    Name = "Public Security Group"
  }

  description = "Public Security Group"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  ingress {
    cidr_blocks = ["102.65.62.201/32"]
    description = "SSH for admin desktop"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["102.134.74.40/32"]
    description = "For admin laptop"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
  }

  name   = "public_sg"
  vpc_id = aws_vpc.my_vpc_01.id
}

# EC2 Instances
# Node API
resource "aws_instance" "node_api" {
  instance_type               = "t2.micro"
  ami                         = "ami-08c40ec9ead489470"
  key_name                    = "week2-keypair"
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  subnet_id                   = aws_subnet.private_subnet.id
  associate_public_ip_address = true
  user_data = (file(
  "userdata.tpl"))
  iam_instance_profile = aws_iam_instance_profile.ec2_profile_ecr_access.name

  # Resize the default size of the drive on this instance
  # AWS default is 8 but can get up 16 on free tier
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "node-api"
  }

}

# React App
resource "aws_instance" "react-app" {
  instance_type               = "t2.micro"
  ami                         = "ami-08c40ec9ead489470"
  key_name                    = "week2-keypair"
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  user_data = (file(
  "userdata-app.tpl"))
  iam_instance_profile = aws_iam_instance_profile.ec2_profile_ecr_access.name

  # Resize the default size of the drive on this instance
  # AWS default is 8 but can get up 16 on free tier
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "react-app"
  }

}
resource "aws_iam_role" "ec2_role_ecr_access" {
  name = "ec2_role_ecr_access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = {
    project = "cloud-module"
  }
}

resource "aws_iam_instance_profile" "ec2_profile_ecr_access" {
  name = "ec2_profile_ecr_access"
  role = aws_iam_role.ec2_role_ecr_access.name
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role_ecr_access.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# resource "aws_db_subnet_group" "testdb" {
#   name       = "testdb"
#   subnet_ids = [aws_subnets.my_vpc_01.public_subnets]

#   tags = {
#     Name = "testdb"
#   }
# }


# Parameter Group
resource "aws_db_parameter_group" "testdb" {
  name   = "testdb"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

### DATABASE
# resource "aws_db_instance" "testdb" {
#   allocated_storage                     = 20
#   auto_minor_version_upgrade            = true
#   availability_zone                     = "us-east-1c"
#   backup_window                         = "04:56-05:26"
#   ca_cert_identifier                    = "rds-ca-2019"
#   copy_tags_to_snapshot                 = true
#   # db_name                               = "testdb"
#   db_subnet_group_name                  = "default"
#   delete_automated_backups              = true
#   engine                                = "postgres"
#   engine_version                        = "14.5"
#   identifier                            = "testdb"
#   instance_class                        = "db.t3.micro"
#   kms_key_id                            = "arn:aws:kms:us-east-1:391551845951:key/28442241-8bdd-40a4-9584-ca15139ed2c4"
#   license_model                         = "postgresql-license"
#   maintenance_window                    = "thu:10:00-thu:10:30"
#   monitoring_interval                   = 60
#   monitoring_role_arn                   = "arn:aws:iam::391551845951:role/rds-monitoring-role"
#   option_group_name                     = "default:postgres-14"
#   parameter_group_name                  = "default.postgres14"
#   performance_insights_enabled          = true
#   performance_insights_kms_key_id       = "arn:aws:kms:us-east-1:391551845951:key/28442241-8bdd-40a4-9584-ca15139ed2c4"
#   performance_insights_retention_period = 7
#   port                                  = 5432
#   publicly_accessible                   = true
#   skip_final_snapshot                   = true
#   storage_encrypted                     = true
#   storage_type                          = "gp2"
#   username                              = "dbuser"
#   vpc_security_group_ids                = ["sg-010baad65060fe539"]
# }

# resource "aws_db_instance" "testdb" {
#   identifier        = "testdb"
#   instance_class    = "db.t2.micro"
#   storage_type      = "gp2"
#   allocated_storage = 5
#   engine            = "postgres"
#   engine_version    = "14.1"
#   username          = "dbuser"
#   password          = var.db_password
#   # db_subnet_group_name       = aws_db_subnet_group.testdb.name
#   # vpc
#   _security_group_ids     = aws_security_group.private_sg.id
#   parameter_group_name       = aws_db_parameter_group.testdb.name
#   publicly_accessible        = true
#   port                       = 5432
#   backup_retention_period    = 1
#   auto_minor_version_upgrade = true
#   deletion_protection        = true
#   skip_final_snapshot        = true
# }

# Input Variables
variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

# Output Variables
# output "rds_hostname" {
#   description = "RDS instance hostname"
#   value       = aws_db_instance.testdb.address
#   sensitive   = true
# }

# output "rds_port" {
#   description = "RDS instance port"
#   value       = aws_db_instance.testdb.port
#   sensitive   = true
# }

# output "rds_username" {
#   description = "RDS instance root username"
#   value       = aws_db_instance.testdb.username
#   sensitive   = true
# }

terraform {
  backend "s3" {
    bucket = "stage-up-and-running-state"
    key    = "terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "stage-up-and-running-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"
}
