terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_route53_zone_association" "vpc_association" {
  count       = length(keys(var.vpc_map)) - 1
  zone_id     = aws_route53_zone.parent.zone_id
  vpc_id      = values(var.vpc_map)[1]
  vpc_region  = keys(var.vpc_map)[1]
}

resource "aws_route53_zone" "parent" {  
  name         = "${var.hosted_zone}" 
  vpc {
    vpc_region = keys(var.vpc_map)[0]
    vpc_id     = values(var.vpc_map)[0]
  }
}

resource "aws_route53_record" "A-records" {
  zone_id = aws_route53_zone.parent.zone_id
  name    = "node${count.index+1}.cluster.${var.subdomain}.${var.hosted_zone}."
  type    = "A"
  ttl     = "60"
  records = [ tostring(var.ip_addresses[count.index]) ]
  count   = length(var.ip_addresses)
}

resource "aws_route53_record" "NS-record" {
  zone_id = aws_route53_zone.parent.zone_id
  name    = "cluster.${var.subdomain}.${var.hosted_zone}."
  type    = "NS"
  ttl     = "60"
  records = formatlist("%s.",tolist(aws_route53_record.A-records.*.name))
}