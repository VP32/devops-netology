# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

/* Инстанс создан через модуль от AWS */
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "netology-ec2-instance"

  ami                    = "ami-0c956e207f9d113d5"
  instance_type          = "t3.micro"
  monitoring             = true

  tags = {
    Name = "Netology Test Instance"
    Terraform   = "true"
    Environment = "dev"
  }
}

/* Инстанс создан через aws_instance */
resource "aws_instance" "web" {
  ami           = "ami-0c956e207f9d113d5"
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "HelloWorld"
  }
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

data "aws_region" "current" {}

output "region" {
  value = data.aws_region.current
}

output "private_ip" {
  value       = aws_instance.web.private_ip
  description = "The private IP of the main server"
}

output "subnet_id" {
  value       = aws_instance.web.subnet_id
  description = "The subnet id"
}

output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP of the main server"
}