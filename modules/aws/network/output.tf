output "vpc" {
  description = "The id of the VPC"
  value       = aws_vpc.vpc.id 
  depends_on = [aws_main_route_table_association.rt-main]
}

output "raw_vpc" {
  description = "The raw VPC object"
  value       = aws_vpc.vpc 
  depends_on = [aws_main_route_table_association.rt-main]
}

output "subnets" {
  description = "The created subnets"
  value       = var.private_conf ? aws_subnet.private-subnets  : aws_subnet.public-subnets
}

output "bastion-subnet" {
  description = "The bastion subnet"
  value       = aws_subnet.bastion-public-subnet
}

output "security-groups" {
  description = "The ids of security groups"
  value       = var.private_conf ? [aws_security_group.allow-local.id] : [aws_security_group.allow-global.id, aws_security_group.allow-local.id]
}

output "bastion-security-groups" {
  description = "The ids of the bastion security groups"
  value       = [aws_security_group.allow-global.id, aws_security_group.allow-local.id]
}