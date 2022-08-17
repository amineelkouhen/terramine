terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
############################################################
# Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-igw"
  })
}

############################################################
# VPC

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-vpc"
  })  
}

############################################################
# Subnets

resource "aws_subnet" "public-subnets" {
  count                   = var.private_conf ? 0 : length(var.subnets_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = values(var.subnets_cidrs)[count.index]
  availability_zone       = keys(var.subnets_cidrs)[count.index]
  map_public_ip_on_launch = true
  
  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-public-subnet-${count.index}"
  })
}

resource "aws_subnet" "private-subnets" {
  count                   = var.private_conf ? length(var.subnets_cidrs) : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = values(var.subnets_cidrs)[count.index]
  availability_zone       = keys(var.subnets_cidrs)[count.index]

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-private-subnet-${count.index}"
  })
}

############################################################
# Route Tables

resource "aws_route_table" "rt-public" {
  count = var.private_conf ? 0 : 1
  vpc_id = aws_vpc.vpc.id

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-rt-public"
  })
}

resource "aws_route_table" "rt-private" {
  count = var.private_conf ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-rt-private"
  })
}

# Associate the main route table to the VPC
resource "aws_main_route_table_association" "rt-main" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = var.private_conf ? aws_route_table.rt-private[0].id : aws_route_table.rt-public[0].id
}

# Associate Public Subnets with Route Table for Internet Gateway
resource "aws_route_table_association" "rt-to-public-subnet" {
  count = var.private_conf ? 0 : length(var.subnets_cidrs)
  subnet_id = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.rt-public[0].id
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "rt-to-private-subnet" {
  count = var.private_conf ? length(var.subnets_cidrs) : 0
  subnet_id = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.rt-private[0].id
}

############################################################
# Route Entries

resource "aws_route" "public-allipv4" {
  count                  = var.private_conf ? 0 : 1
  route_table_id         = aws_route_table.rt-public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public-allowipv6" {
  count                       = var.private_conf ? 0 : 1
  route_table_id              = aws_route_table.rt-public[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}

resource "aws_route" "private-allipv4" {
  count                  = var.private_conf ? 1 : 0
  route_table_id         = aws_route_table.rt-private[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway[0].id
}

############################################################
# NAT Gateway

# Elastic IP for NAT Gateway
resource "aws_eip" "eip-nat" {
  count = var.private_conf ? 1 : 0
  vpc   = true

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-eip-nat"
  })
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.private_conf ? 1 : 0
  allocation_id = aws_eip.eip-nat[count.index].id
  subnet_id     = aws_subnet.bastion-public-subnet[count.index].id

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-nat-gateway"
  })
}

############################################################
# Bastion Subnet

resource "aws_subnet" "bastion-public-subnet" {
  count                   = (var.private_conf || var.client_enabled) ? 1 : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = values(var.bastion_subnet_cidr)[0]
  availability_zone       = keys(var.bastion_subnet_cidr)[0]
  map_public_ip_on_launch = true
  
  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-bastion-public-subnet"
  })
}

############################################################
# Route Tables

resource "aws_route_table" "bastion-rt-public" {
  count  = (var.private_conf || var.client_enabled) ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-bastion-rt-public"
  })
}

# Associate Public Subnets with Route Table for Internet Gateway
resource "aws_route_table_association" "bastion-rt-to-public-subnet" {
  count  = (var.private_conf || var.client_enabled) ? 1 : 0
  subnet_id = aws_subnet.bastion-public-subnet[count.index].id
  route_table_id = aws_route_table.bastion-rt-public[count.index].id
}

############################################################
# Bastion Route Entries

resource "aws_route" "bastion-public-allipv4" {
  count                  = (var.private_conf || var.client_enabled) ? 1 : 0
  route_table_id         = aws_route_table.bastion-rt-public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "bastion-public-allowipv6" {
  count                       = (var.private_conf || var.client_enabled) ? 1 : 0
  route_table_id              = aws_route_table.bastion-rt-public[count.index].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}