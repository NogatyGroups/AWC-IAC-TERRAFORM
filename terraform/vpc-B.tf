##########################################################################################################
# VPC PEERING Provider
##########################################################################################################
provider "aws" {
    region = "eu-central-1"
    alias = "vpc-b"
  
}


##########################################################################################################
# VPC PEERING
##########################################################################################################
## Create VPC B
resource "aws_vpc" "vpc-b" {
    provider = aws.vpc-b
    cidr_block = var.cidr-block-b
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = var.nogaty-eu-central-vpc
    }
}


##########################################################################################################
# CREATE SUBNETS
##########################################################################################################

resource "aws_internet_gateway" "igw-b" {
  vpc_id = aws_vpc.vpc-b.id 
  tags = {
    Name = var.igw-vpcb
    env = var.env 
  }
  depends_on = [ aws_vpc.vpc-b ]
}


### Create public subnet B
resource "aws_subnet" "public-subnet-b" {
    count = var.pub-subnet-count-b
    vpc_id = aws_vpc.vpc-b.id
    cidr_block = element(var.pub-cidr-block-b, count.index)
    availability_zone = element(var.pub-availability-zone-b, count.index)
    map_public_ip_on_launch = true 
    tags = {
        Name = "${var.pub-sub-name-b}-${count.index +1 }"
        Env = var.env 
    }
    depends_on = [ aws_vpc.vpc-b, ]
  
}

### Create private subnet B
resource "aws_subnet" "private-subnet-b" {
    count = var.pri-subnet-count-b
    vpc_id = aws_vpc.vpc-b.id 
    cidr_block = element(var.pri-cidr-block-b, count.index)
    availability_zone = element(var.pri-availability-zone-b, count.index)
    map_public_ip_on_launch = false 
    tags = {
        Name = "${var.pri-sub-name-b}-${count.index + 1}"
        Env = var.env 
    }
    depends_on = [ aws_vpc.vpc-b, ]
  
}



### Create public route table B
resource "aws_route_table" "public-rt-b" {
  vpc_id = aws_vpc.vpc-b.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-b.id
  }
  tags = {
    Name = var.public-rtb-name 
    env = var.env
  }
  depends_on = [ aws_vpc.vpc-b ]
}

### Associate public route table to public subnet B
resource "aws_route_table_association" "public-rtb-association" {
  count = 3
  route_table_id = aws_route_table.public-rt-b.id 
  subnet_id = aws_subnet.public-subnet-b[count.index].id 
  depends_on = [ aws_vpc.vpc-b, aws_subnet.public-subnet-b ]
}



#### Create Elastic IP for Nat Gateway B
#resource "aws_eip" "ngw-eip-b" {
#  domain = "vpc-b"
#  tags = {
#    Name = var.eip-name-b
#  }
#    depends_on = [ aws_vpc.vpc-b ]
#}

#resource "aws_nat_gateway" "ngw-b" {
#    allocation_id = aws_eip.ngw-eip-b.id
#    subnet_id = aws_subnet.public-subnet-b[0].id
#    tags = {
#        Name = var.ngw-name-b
#    }
#    depends_on = [ aws_vpc.vpc-b, aws_eip.ngw-eip-b ]
#}

#### Create Private route table B
#resource "aws_route_table" "private-rtb" {
#  vpc_id = aws_vpc.vpc-b.id 
#  route {
#    cidr_block = "0.0.0.0/0"
#    nat_gateway_id = aws_nat_gateway.ngw-b.id
#  }
#  tags = {
#    Name = var.private-rta-name
#    env = var.env
#  }
#  depends_on = [ aws_vpc.vpc-b, ]
#}
#
#
#### Associate private route table with private subnet B
#resource "aws_route_table_association" "private-rtb-association" {
#    count = 3 
#    route_table_id = aws_route_table.private-rtb.id 
#    subnet_id = aws_subnet.private-subnet-b[count.index].id
#    depends_on = [ aws_vpc.vpc-b, aws_subnet.private-subnet-b ]
#}

### Create securitty group B
resource "aws_security_group" "security-sg-b" {
    name = var.sg-b-name
    description = "Allow 443 from jump server only"
    vpc_id = aws_vpc.vpc-b.id 

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
      Name = var.sg-b-name
    }
    
}