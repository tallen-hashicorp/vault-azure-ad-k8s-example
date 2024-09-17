terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# The number of instances required
variable "instance_count" {
  default = 1
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "default" {
  key_name   = "my-key" # Name of the key in AWS
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public key file
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access_sg"
  description = "Security group allowing inbound SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "boundary_access" {
  name        = "boundary_access_sg"
  description = "Security group allowing inbound boundary access"

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "vault_access" {
  name        = "vault_access_sg"
  description = "Security group allowing inbound boundary access"

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8220
    to_port     = 8220
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
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "internal_traffic" {
  name_prefix = "internal_traffic"
  description = "Allow all internal traffic to EC2 instance"

  # Ingress rule to allow all internal traffic
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["172.31.32.0/20"] # Replace with your internal IP range (e.g., your VPC's CIDR block)
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "this" {
  count    = var.instance_count  
  domain   = "vpc"
  instance = aws_instance.vault[count.index].id
}

resource "aws_instance" "vault" {
  count                       = var.instance_count
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.ssh_access.id}", "${aws_security_group.boundary_access.id}", "${aws_security_group.internal_traffic.id}", "${aws_security_group.vault_access.id}"]
  key_name                    = aws_key_pair.default.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
            #!/bin/bash
            # Update the package list and install Apache web server
            sudo apt-get update -y
            sudo apt update -y
            sudo apt install nginx certbot python3-certbot-nginx unzip jq -y
            sudo systemctl enable nginx
            wget https://releases.hashicorp.com/vault/1.17.5+ent/vault_1.17.5+ent_linux_amd64.zip
            unzip vault_1.17.5+ent_linux_amd64.zip
            sudo mv vault /usr/bin
            EOF

  tags = {
    Name = "DELETE_ME"
  }
}

