############################################################
# VPC Peering

provider "aws" {
    alias               = "requester"
    region              = var.requester_region
  }

  provider "aws" {
    alias               = "accepter"
    region              = var.peer_region
  }

  resource "aws_vpc_peering_connection" "peering" {
    provider      = aws.requester
    vpc_id        = var.requester_vpc.id
    peer_vpc_id   = var.peer_vpc.id
    peer_region   = var.peer_region
    auto_accept   = false

    tags = {
      Name = var.name
    }
  }

  resource "aws_vpc_peering_connection_accepter" "peer" {
    provider                  = aws.accepter
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
    auto_accept               = true

    tags = {
      Side = "Peering Accepter"
    }
  }

  resource "aws_vpc_peering_connection_options" "requester" {
    provider      = aws.requester
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
    depends_on = [aws_vpc_peering_connection_accepter.peer]

    requester {
      allow_remote_vpc_dns_resolution = true
    }
  }

  resource "aws_vpc_peering_connection_options" "accepter" {
    provider                  = aws.accepter
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
    depends_on = [aws_vpc_peering_connection_accepter.peer]

    accepter {
      allow_remote_vpc_dns_resolution = true
    }
  }

############################################################
# Route Entries

resource "aws_route" "requester-to-accepter" {
  provider                  = aws.requester
  route_table_id            = var.requester_vpc.main_route_table_id
  destination_cidr_block    = var.peer_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "accepter-to-requester" {
  provider                  = aws.accepter
  route_table_id            = var.peer_vpc.main_route_table_id
  destination_cidr_block    = var.requester_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}