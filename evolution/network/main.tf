terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.2"
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

locals {
  subnets_flat = flatten([
    for vpc_name, subnets in var.vpc : [
      for subnet_name, config in subnets : {
        vpc_key      = vpc_name
        subnet_key   = subnet_name
        subnet       = config["subnet"]
        zone         = config["zone"]
      }
    ]
  ])
}

resource "cloudru_evolution_vpc_vpc" "this" {
  for_each    = var.vpc
  project_id  = var.project_id
  name        = each.key
  description = var.description
}

resource "cloudru_evolution_compute_subnet" "this" {
  for_each = {
    for s in local.vpc : "${s.vpc_key}.${s.subnet_key}" => s
  }
  project_id     = var.project_id
  name           = each.value.subnet_key
  vpc_id         = cloudru_evolution_vpc_vpc.this[each.value.vpc_key].id
  subnet_address = each.value.subnet
  routed_network = true

  zone_identifier = {
    name = each.value.zone
  }

  default = true
}
