terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
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

resource "google_dns_record_set" "NS-record" {
  managed_zone = var.hosted_zone_name
  name         = "cluster.${var.subdomain}.${var.hosted_zone}."
  type         = "NS"
  rrdatas      = formatlist("%s",tolist(google_dns_record_set.A-records.*.name))
  ttl          = 60
}