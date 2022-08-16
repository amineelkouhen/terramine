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
    vpc_id        = var.requester_vpc
    peer_vpc_id   = var.peer_vpc
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
