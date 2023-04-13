# Define provider and required packages
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_key_pair" "visie_server_key" {
  key_name   = "visie_server_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Configure AWS provider with your access and secret keys
provider "aws" {
  access_key = "AKIASI73ANDDKEYLCS27"
  secret_key = "+KJASECRETKEY"
  region     = "ap-southeast-1"
}

# Define security group with necessary inbound rules
resource "aws_security_group" "visie-server-sg" {
  name_prefix = "visie-server-sg"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define IAM role and instance profile for EC2 instance
resource "aws_iam_role" "visie-server-role" {
  name = "visie-server-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {sensitive = true}
    ]
  })
}

resource "aws_iam_instance_profile" "visie-server-profile" {
  name = "visie-server-profile"
  
  role = aws_iam_role.visie-server-role.name
}

# Define EC2 instance with Ubuntu 20.04 AMI, and associate with security group and instance profile
resource "aws_instance" "visie-server" {
  ami           = "ami-0a72af05d27b49ccb" # Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  key_name      = aws_key_pair.visie_server_key.key_name
  
  vpc_security_group_ids = [aws_security_group.visie-server-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.visie-server-profile.name
  
  tags = {
    Name = "visie-server"
  }
}

resource "tls_private_key" "visie_server_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

output "private_key_pem" {
  value = tls_private_key.visie_server_key.private_key_pem
   sensitive = true
}

output "public_key_pem" {
  value = tls_private_key.visie_server_key.public_key_pem

}

resource "local_file" "private_key_file" {
  content  = tls_private_key.visie_server_key.private_key_pem
  filename = "visie_server_key.pem"

}
