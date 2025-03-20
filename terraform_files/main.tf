provider "aws" {
  region = var.aws_region
}

# Create Key Pair
resource "aws_key_pair" "deployer_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "instance_security_group"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# CICD Machine
resource "aws_instance" "cicd_machine" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer_key.key_name
  security_groups = [aws_security_group.instance_sg.name]

  tags = {
    Name = "CICD-machine"
  }
}

# Production Machine
resource "aws_instance" "production_machine" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer_key.key_name
  security_groups = [aws_security_group.instance_sg.name]

  tags = {
    Name = "Production-machine"
  }
}
