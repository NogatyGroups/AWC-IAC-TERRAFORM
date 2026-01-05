## Random
resource "random_pet" "sg" {}

## Create AWS VPC

resource "aws_vpc" "nogaty-githubaction-vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "nogaty-githubaction-vpc"
  }
}

## Create subnets 
resource "aws_subnet" "nogaty-githubaction-subnet" {
    vpc_id = aws_vpc.nogaty-githubaction-vpc.id
    cidr_block = "172.16.10.0/24"
    tags = {
        Name = "nogaty-githubaction-subnet"
    }
}

## AWS Network Interfaces
resource "aws_network_interface" "aws-Network-interfaces" {
    subnet_id = aws_subnet.nogaty-githubaction-subnet.id 
    private_ips = ["172.16.10.100"]
    tags = {
        Name = "Nogaty-NIC"
    }
}

## AWS Security group
resource "aws_security_group" "aws-sg" {
  vpc_id = aws_vpc.nogaty-githubaction-vpc.id 
  name = "${random_pet.sg.id}-sg"
  region = "us-east-1"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

## Create AWS EC2 Instance
resource "aws_instance" "NogatyWeb" {
    ami = "ami-068c0051b15cdb816"
    instance_type = "t3.micro"
    network_interface {
      network_interface_id = aws_network_interface.aws-Network-interfaces.id
      device_index = 0
    }
    tags = {
      Name = "NogatyWeb"
    }
  
}