# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Modify to your desired region
}

# Use a data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Create a security group for the Jenkins instance
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_security_group"
  description = "Allow SSH and Jenkins ports"

  # Ingress rule for SSH (port 22) - restrict cidr_blocks to your public IP for security
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Open to the world, restrict this in production
  }

  # Ingress rule for Jenkins (port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule for all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 instance
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro" # t2.micro might be insufficient; adjust instance type as needed
  # Ensure you have a key pair created in AWS for SSH access
  # key_name = "keypair-ananth" 

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data              = file("jenkins_install.sh") # Reference the install script

  tags = {
    Name = "Jenkins-Server"
  }
}

# Output the public IP to access Jenkins after deployment
output "jenkins_url" {
  value = join("", ["http://", aws_instance.jenkins_server.public_ip, ":8080"])
}

