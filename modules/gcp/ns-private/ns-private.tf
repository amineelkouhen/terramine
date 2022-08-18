terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

resource "google_dns_managed_zone" "private-zone" {
  name            = var.hosted_zone_name
  dns_name        = "${var.hosted_zone}."
  description     = "${var.hosted_zone_name} private DNS zone"
  visibility      = "private"

  private_visibility_config {
    networks {
      network_url = values(var.vpc_map)[0]
    }
  }
}

resource "google_dns_record_set" "A-records" {
  managed_zone = var.hosted_zone_name
  name         = "node${count.index+1}.cluster.${var.subdomain}.${var.hosted_zone}."
  type         = "A"
  rrdatas      = [ tostring(var.ip_addresses[count.index]) ]
  ttl          = 60
  count        = length(var.ip_addresses)
}

resource "google_dns_record_set" "CNAME-record" {
  managed_zone = var.hosted_zone_name
  name         = "cluster.${var.subdomain}.${var.hosted_zone}."
  type         = "CNAME"
  rrdatas      = [tostring(google_dns_record_set.A-records[0].name)]
  ttl          = 60
}