# General ------------------

terraform {
  required_version = "~> 1.9.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Networking ------------------

## INFO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "myvpc"
  }
}

## INFO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mygateway"
  }
}

## INFO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "mysubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "mysubnet"
  }
}

# SSH
resource "aws_security_group" "ingress-ssh" {
  name   = "ingress-ssh"
  vpc_id = aws_vpc.myvpc.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ingress-ssh"
  }
}

resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygateway.id
  }
  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.my-route-table.id
}

# EC2 Instance (ubuntu server) ------------------

## INFO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ubuntu2404" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.mysubnet.id
  depends_on                  = [aws_internet_gateway.mygateway, aws_vpc.myvpc]
  security_groups             = [aws_security_group.ingress-ssh.id]
  associate_public_ip_address = true

  # INFO: Needed for Kamal to work: https://github.com/basecamp/kamal/issues/246
  user_data = <<-EOL
    #!/bin/bash -xe
    sudo usermod -aG docker ubuntu
  EOL

  # SSH 
  key_name             = "vockey"             # Vockey is added by the aws lab by default
  iam_instance_profile = "LabInstanceProfile" # LabInstanceProfile is added by the aws lab by default
  tags = {
    Name = "ubuntu2404"
  }
}

output "ubuntu2404_public_ip" {
  value = aws_instance.ubuntu2404.*.public_ip
}

# Container Registry auf AWS ------------------

# INFO : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "myecr" {
  name                 = "m32c4/ecr-repository"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "myecr"
  }
}
