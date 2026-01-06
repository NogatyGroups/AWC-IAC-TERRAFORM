##########################################################################################################
# VPC PEERING
##########################################################################################################

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
