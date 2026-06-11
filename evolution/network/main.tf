terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.0"
    }
  }
}
provider "cloudru" {
  project_id   = var.project_id
  customer_id  = var.customer_id
  auth_key_id  = var.auth_key_id
  auth_secret  = var.auth_secret
  endpoints = {
    iam_endpoint            = "iam.api.cloud.ru:443"
    object_storage_endpoint = "https://s3.cloud.ru"
    kafka_endpoint          = "kafka.api.cloud.ru:443"
    redis_endpoint          = "redis.api.cloud.ru:443"
    compute_endpoint        = "compute.api.cloud.ru:443"
    baremetal_endpoint      = "baremetal.api.cloud.ru:443"
    vpc_endpoint            = "vpc.api.cloud.ru:443"
    magic_router_endpoint   = "magic-router.api.cloud.ru"
    dns_endpoint            = "dns.api.cloud.ru:443"
    nlb_endpoint            = "nlb.api.cloud.ru"
  }
}

resource "cloudru_evolution_vpc_vpc" "this" {
  project_id  = var.project_id
  name        = var.name
  description = var.description
}

resource "cloudru_evolution_compute_subnet" "this" {
  project_id     = var.project_id
  name           = var.subnet_name
  vpc_id         = cloudru_evolution_vpc_vpc.this.id
  subnet_address = var.subnet_address
  routed_network = true

  zone_identifier = {
    name = var.zone
  }

  default = true
}
