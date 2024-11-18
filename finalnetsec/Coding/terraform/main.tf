# Define the AWS provider and region
provider "aws" {
  region = "us-east-1"
}

# Create a Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = var.vpc_id
  # Inbound rule to allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule to allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my-ec2-key" {
  key_name   = "my-ec2-key"
  public_key = file("/home/dhiraj/dhiraj/my-ec2-key.pub")
}

# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name      = aws_key_pair.my-ec2-key.key_name

  associate_public_ip_address = true

  tags = {
    Name = "WebServer"
  }
}

# Outputs
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_sg.id
}