terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_route53_zone" "hosted_zone" {
  name         = "${var.hosted_zone}."
  private_zone = false
}

resource "aws_route53_record" "A-records" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "node${count.index+1}.cluster.${var.subdomain}.${var.hosted_zone}."
  type    = "A"
  ttl     = "60"
  records = [ tostring(var.ip_addresses[count.index]) ]
  count   = length(var.ip_addresses)
}

resource "aws_route53_record" "NS-record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "cluster.${var.subdomain}.${var.hosted_zone}."
  type    = "NS"
  ttl     = "60"
  records = formatlist("%s.",tolist(aws_route53_record.A-records.*.name))
}