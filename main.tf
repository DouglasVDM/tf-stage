
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
resource "aws_security_group" "private_sg" {
  tags = {
    Name = "Private Security Group"
  }

  tags_all = {
    Name = "private_sg"
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

  tags_all = {
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

# EC2 Instance
resource "aws_instance" "node_api" {
  instance_type               = "t2.micro"
  ami                         = "ami-08c40ec9ead489470"
  key_name                    = "week2-keypair"
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  subnet_id                   = aws_subnet.private_subnet.id
  associate_public_ip_address = true
  user_data                   = file("userdata.tpl")

  # Resize the default size of the drive on this instance
  # AWS default is 8 but can get up 16 on free tier
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "node-api"
  }

}

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