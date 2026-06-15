terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.2"
    }
  }
}
provider "cloudru" {
  project_id  = var.project_id
  customer_id = var.customer_id
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret
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
data "cloudru_evolution_compute_zone_collection" "all" {
  project_id = var.project_id
}

locals {
  all_zones = data.cloudru_evolution_compute_zone_collection.all.zones

  sg_zone_list = flatten([
    for sg_name, rules in var.sg_rules : [
      for zone in local.all_zones : {
        key       = "${sg_name}-${zone.short_name}"
        sg_name   = sg_name
        zone_name = zone.name
      }
    ]
  ])

  sg_zone_map = {
    for item in local.sg_zone_list : item.key => item
  }

  flat_rules = flatten([
    for sg_name, rules in var.sg_rules : [
      for rule in rules : [
        for subnet in rule.subnets : [
          for zone in local.all_zones : {
            id               = "${sg_name}-${zone.short_name}-${rule.direction}-${rule.protocol}-${rule.port}-${subnet}"
            sg_key           = "${sg_name}-${zone.short_name}"
            direction        = rule.direction
            protocol         = rule.protocol
            port             = rule.port
            remote_ip_prefix = subnet
          }
        ]
      ]
    ]
  ])
}

resource "cloudru_evolution_compute_security_group" "this" {
  for_each = local.sg_zone_map

  project_id = var.project_id

  zone_identifier = {
    name = each.value.zone_name
  }

  name        = each.key
  description = "TF management sg"
}

resource "cloudru_evolution_compute_security_group_rule" "this" {
  for_each = {
    for rule in local.flat_rules : rule.id => rule
  }

  security_group_id = cloudru_evolution_compute_security_group.this[each.value.sg_key].id
  direction         = each.value.direction == "ingress" ? "TRAFFIC_DIRECTION_INGRESS" : "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = each.value.protocol
  port_range        = each.value.port
  remote_ip_prefix  = each.value.remote_ip_prefix
  description       = "${each.value.sg_key} rule for ${each.value.remote_ip_prefix}"
}
