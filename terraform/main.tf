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
  cidr_block = "10.0.0.0/16"
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

# EC2 Instance (ubuntu server) ------------------

## INFO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
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

# output "ubuntu2404_public_ip" {
#   value = aws_instance.ubuntu2404[0].public_ip
# }

# Container Registry auf AWS ------------------

# HACK: Fix error when registry already exists https://stackoverflow.com/a/75277686
data "external" "check_repo" {
  program = ["/usr/bin/bash", "${path.module}/check_aws_repository_exists.sh", "m32c4/ecr-repository", "us-east-1"]
}

# INFO : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "myecr" {
  count                = data.external.check_repo.result.success == "true" ? 0 : 1
  name                 = "m32c4/ecr-repository"
  image_tag_mutability = "IMMUTABLE"
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
