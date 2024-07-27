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

resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mygateway"
  }
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "mysubnet"
  }
}

resource "aws_instance" "ubuntu2404" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.nano"
  subnet_id                   = aws_subnet.mysubnet.id
  depends_on                  = [aws_internet_gateway.mygateway, aws_vpc.myvpc]
  associate_public_ip_address = true
  tags = {
    Name = "ubuntu2404"
  }
}

resource "aws_ecr_repository" "ecr" {
  name                 = "m32c4/ecr-repository"
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "ecr-repository"
  }
}
