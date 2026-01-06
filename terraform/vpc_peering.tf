##########################################################################################################
# VPC PEERING
##########################################################################################################
## Create VPC A 
resource "aws_vpc" "nogaty-us-east-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = var.nogaty-us-east-vpc
  }
}


## Create VPC B
resource "aws_vpc" "nogaty-us-west-vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = var.nogaty-us-west-vpc
  }
}


### Create Peering between VPC-A and VPC-B
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_owner_id = var.peer-owner-id
  peer_region = var.peer-region
  peer_vpc_id = aws_vpc.nogaty-us-west-vpc.id 
  vpc_id = aws_vpc.nogaty-us-east-vpc.id
  auto_accept = false
  accepter {
    allow_remote_vpc_dns_resolution = true
    }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Name = var.peering-vpc-name
  }
}