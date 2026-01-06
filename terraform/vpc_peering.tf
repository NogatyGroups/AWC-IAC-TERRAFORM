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
resource "aws_vpc" "vpc-a" {
    provider = aws.vpc-a
    cidr_block = var.cidr-block-a
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = var.nogaty-us-east-vpc
    }
}


## Create VPC B
resource "aws_vpc" "vpc-b" {
    provider = aws.vpc-b
    cidr_block = var.cidr-block-b
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
  peer_vpc_id = aws_vpc.vpc-b.id 
  vpc_id = aws_vpc.vpc-a.id
  auto_accept = false
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


### Create public subnet A and B
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
    depends_on = [ aws_vpc.vpc, ]
  
}

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

### Create private subnet A and B
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
  depends_on = [ aws_vpc.vpc ]
}

resource "aws_route_table" "public-rt-b" {
  vpc_id = aws_vpc.vpc-b.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway-b.igw.id
  }
  tags = {
    Name = var.public-rtb-name 
    env = var.env
  }
  depends_on = [ aws_vpc.vpc ]
}

### Associate public route table to public subnet A and B
resource "aws_route_table_association" "public-rta-association" {
  count = 3
  route_table_id = aws_route_table.public-rta.id 
  subnet_id = aws_subnet.public-subnet-a[count.index].id 
  depends_on = [ aws_vpc-a.vpc, aws_subnet.public-subnet-a ]
}


resource "aws_route_table_association" "public-rtb-association" {
  count = 3
  route_table_id = aws_route_table.public-rtb.id 
  subnet_id = aws_subnet.public-subnet-b[count.index].id 
  depends_on = [ aws_vpc-b.vpc, aws_subnet.public-subnet-b ]
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
#### Create Elastic IP for Nat Gateway
#resource "aws_eip" "ngw-eip-b" {
#  domain = "vpc-b"
#  tags = {
#    Name = var.eip-name-b
#  }
#    depends_on = [ aws_vpc.vpc-b ]
#}
#
#
#### Create Nat Gateway A and B
#resource "aws_nat_gateway" "ngw-a" {
#    allocation_id = aws_eip.ngw-eip-a.id
#    subnet_id = aws_subnet.public-subnet-a[0].id
#    tags = {
#        Name = var.ngw-name-a
#    }
#    depends_on = [ aws_vpc.vpc-a, aws_eip.ngw-eip-a ]
#}
#
#resource "aws_nat_gateway" "ngw-b" {
#    allocation_id = aws_eip.ngw-eip-b.id
#    subnet_id = aws_subnet.public-subnet-b[0].id
#    tags = {
#        Name = var.ngw-name-b
#    }
#    depends_on = [ aws_vpc.vpc-b, aws_eip.ngw-eip-b ]
#}

#### Create Private route table A and B
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
#### Associate private route table with private subnet A and B
#resource "aws_route_table_association" "private-rta-association" {
#    count = 3 
#    route_table_id = aws_route_table.private-rta.id 
#    subnet_id = aws_subnet.private-subnet-a[count.index].id
#    depends_on = [ aws_vpc.vpc-a, aws_subnet.private-subnet-a ]
#}
#
#resource "aws_route_table_association" "private-rtb-association" {
#    count = 3 
#    route_table_id = aws_route_table.private-rtb.id 
#    subnet_id = aws_subnet.private-subnet-b[count.index].id
#    depends_on = [ aws_vpc.vpc-b, aws_subnet.private-subnet-b ]
#}

### Create securitty group A and B
resource "aws_security_group" "security-sg-a" {
    name = var.sg-a-name
    description = "Allow 443 from jump server only"
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