##########################################################################################################
# VPC PEERING Provider
##########################################################################################################
provider "aws" {
  region = "us-east-1"
  alias = "vpc-a"
}

provider "aws" {
    region = "us-west-1"
    alias = "vpc-b"
  
}


##########################################################################################################
# VPC PEERING
##########################################################################################################
## Create VPC A 
resource "aws_vpc" "nogaty-us-east-vpc" {
    provider = aws.vpc-a
    cidr_block = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = var.nogaty-us-east-vpc
    }
}


## Create VPC B
resource "aws_vpc" "nogaty-us-west-vpc" {
    provider = aws.vpc-b
    cidr_block = "192.168.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = var.nogaty-us-west-vpc
    }
}

locals {
  peer-owner-id = var.aws_account_id
}
### Create Peering between VPC-A and VPC-B
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_owner_id = local.peer-owner-id
  peer_region = var.peer-region
  peer_vpc_id = aws_vpc.nogaty-us-west-vpc.id 
  vpc_id = aws_vpc.nogaty-us-east-vpc.id
  auto_accept = false
  #accepter {
  #  allow_remote_vpc_dns_resolution = true
  #  }
  #requester {
  #  allow_remote_vpc_dns_resolution = true
  #}
  tags = {
    Name = var.peering-vpc-name
  }
}

### Create aws_vpc_peering_acceptar
resource "aws_vpc_peering_connection_accepter" "accepter-peer" {
  region                    = var.peer-region
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

### aws_vpc_peering_connection_options requester
resource "aws_vpc_peering_connection_options" "requester" {
  provider = aws.vpc-a

  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter-peer.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  depends_on = [ aws_vpc_peering_connection_accepter.accepter-peer ]
}

### aws_vpc_peering_connection_options accepter
resource "aws_vpc_peering_connection_options" "accepter" {
  provider = aws.vpc-b

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter-peer.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  depends_on = [ aws_vpc_peering_connection_accepter.accepter-peer ]
}



##########################################################################################################
# CREATE SUBNETS
##########################################################################################################
locals {
  cluster_name = var.cluster-name
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

resource "aws_internet_gateway" "igw-b" {
  vpc_id = aws_vpc.vpc-b.id 
  tags = {
    Name = var.igw-vpcb
    env = var.env 
  }
  depends_on = [ aws_vpc.vpc-b ]
}


### Create public subnet
resource "aws_subnet" "public-subnet" {
    count = var.pub-subnet-count
    vpc_id = aws_vpc.vpc.id
    cidr_block = element(var.pub-cidr-block, count.index)
    availability_zone = element(var.pub-availability-zone, count.index)
    map_public_ip_on_launch = true 
    tags = {
        Name = "${var.pub-sub-name}-${count.index +1 }"
        Env = var.env 
        "kubernetes.io/cluster/${local.cluster-name}" = "owned"
        "kubernetes.io/role/elb"  = "1"
    }
    depends_on = [ aws_vpc.vpc, ]
  
}

### Create private subnet
resource "aws_subnet" "private-subnet" {
    count = var.pri-subnet-count
    vpc_id = aws_vpc.vpc.id 
    cidr_block = element(var.pri-cidr-block, count.index)
    availability_zone = element(var.pri-availability-zone, count.index)
    map_public_ip_on_launch = false 
    tags = {
        Name = "${var.pri-sub-name}-${count.index + 1}"
        Env = var.env 
        "kubernetes.io/cluster/${local.cluster-name}" = "owned"
        "kubernetes.io/role/internal-elb"  = "1"
    }
    depends_on = [ aws_vpc.vpc, ]
  
}

### Create public route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.public-rt-name 
    env = var.env
  }
  depends_on = [ aws_vpc.vpc ]
}

### Associate public route table to public subnet
resource "aws_route_table_association" "public-rt-association" {
  count = 3
  route_table_id = aws_route_table.public-rt.id 
  subnet_id = aws_subnet.public-subnet[count.index].id 
  depends_on = [ aws_vpc.vpc, aws_subnet.public-subnet ]
}

### Create Elastic IP for Nat Gateway
resource "aws_eip" "ngw-eip" {
  domain = "vpc"
  tags = {
    Name = var.eip-name
  }
    depends_on = [ aws_vpc.vpc ]
}


### Create Nat Gateway
resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.ngw-eip.id
    subnet_id = aws_subnet.public-subnet[0].id
    tags = {
        Name = var.ngw-name
    }
    depends_on = [ aws_vpc.vpc, aws_eip.ngw-eip ]
}

### Create Private route table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = var.private-rt-name
    env = var.env
  }
  depends_on = [ aws_vpc.vpc, ]
}

### Associate private route table with private subnet
resource "aws_route_table_association" "private-rt-association" {
    count = 3 
    route_table_id = aws_route_table.private-rt.id 
    subnet_id = aws_subnet.private-subnet[count.index].id
    depends_on = [ aws_vpc.vpc, aws_subnet.private-subnet ]
}


### Create securitty group
resource "aws_security_group" "eks-cluster-sg" {
    name = var.eks-sg
    description = "Allow 443 from jump server only"
    vpc_id = aws_vpc.vpc.id 

    ingress {
        from_port = 443
        to_port = 443
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
      Name = var.eks-sg
    }
    
}