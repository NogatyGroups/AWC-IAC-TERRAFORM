##########################################################################################################
# VPC PEERING Provider
##########################################################################################################
provider "aws" {
  region = "us-east-1"
  alias = "vpc-a"
}

##########################################################################################################
# VPC PEERING
##########################################################################################################
## Create VPC A 
resource "aws_vpc" "vpc-a" {
    provider = aws.vpc-a
    cidr_block = var.cidr-block-a
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = var.nogaty-us-east-vpc
    }
}


locals {
  peer-owner-id = var.aws_account_id
}


##########################################################################################################
# CREATE SUBNETS
##########################################################################################################

### Create public subnet A
resource "aws_subnet" "public-subnet-a" {
    count = var.pub-subnet-count-a
    vpc_id = aws_vpc.vpc-a.id
    cidr_block = element(var.pub-cidr-block-a, count.index)
    availability_zone = element(var.pub-availability-zone-a, count.index)
    map_public_ip_on_launch = true 
    tags = {
        Name = "${var.pub-sub-name-a}-${count.index +1 }"
        Env = var.env 
    }
    depends_on = [ aws_vpc.vpc-a, ]
  
}

### Create internet gateway
resource "aws_internet_gateway" "igw-a" {
  vpc_id = aws_vpc.vpc-a.id 
  tags = {
    Name = var.igw-vpca
    env = var.env 
  }
  depends_on = [ aws_vpc.vpc-a ]
}



### Create private subnet A 
resource "aws_subnet" "private-subnet-a" {
    count = var.pri-subnet-count-a
    vpc_id = aws_vpc.vpc-a.id 
    cidr_block = element(var.pri-cidr-block-a, count.index)
    availability_zone = element(var.pri-availability-zone-a, count.index)
    map_public_ip_on_launch = false 
    tags = {
        Name = "${var.pri-sub-name-a}-${count.index + 1}"
        Env = var.env 
    }
    depends_on = [ aws_vpc.vpc-a, ]
  
}


### Create public route table
resource "aws_route_table" "public-rt-a" {
  vpc_id = aws_vpc.vpc-a.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-a.id
  }
  tags = {
    Name = var.public-rta-name 
    env = var.env
  }
  depends_on = [ aws_vpc.vpc-a ]
}

### Associate public route table to public subnet A and B
resource "aws_route_table_association" "public-rta-association" {
  count = 3
  route_table_id = aws_route_table.public-rt-a.id 
  subnet_id = aws_subnet.public-subnet-a[count.index].id 
  depends_on = [ aws_vpc.vpc-a, aws_subnet.public-subnet-a ]
}


#### Create Elastic IP for Nat Gateway
#resource "aws_eip" "ngw-eip-a" {
#  domain = "vpc-a"
#  tags = {
#    Name = var.eip-name-a
#  }
#    depends_on = [ aws_vpc.vpc-a ]
#}

#
#
#### Create Nat Gateway A 
#resource "aws_nat_gateway" "ngw-a" {
#    allocation_id = aws_eip.ngw-eip-a.id
#    subnet_id = aws_subnet.public-subnet-a[0].id
#    tags = {
#        Name = var.ngw-name-a
#    }
#    depends_on = [ aws_vpc.vpc-a, aws_eip.ngw-eip-a ]
#}
#


#### Create Private route table A 
#resource "aws_route_table" "private-rta" {
#  vpc_id = aws_vpc.vpc-a.id 
#  route {
#    cidr_block = "0.0.0.0/0"
#    nat_gateway_id = aws_nat_gateway.ngw-a.id
#  }
#  tags = {
#    Name = var.private-rta-name
#    env = var.env
#  }
#  depends_on = [ aws_vpc.vpc-a, ]
#}

#
#
#### Associate private route table with private subnet A 
#resource "aws_route_table_association" "private-rta-association" {
#    count = 3 
#    route_table_id = aws_route_table.private-rta.id 
#    subnet_id = aws_subnet.private-subnet-a[count.index].id
#    depends_on = [ aws_vpc.vpc-a, aws_subnet.private-subnet-a ]
#}


### Create securitty group A 
resource "aws_security_group" "security-sg-a" {
    name = var.sg-a-name
    description = "Allow ssh from jump server only"
    vpc_id = aws_vpc.vpc-a.id 

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
      Name = var.sg-a-name
    }
    
}
