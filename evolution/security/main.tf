locals {
  flat_rules = flatten([
    for sg_name, rules in var.sg_rules : [
      for rule in rules : [
        for subnet in rule.subnets : {
          id               = "${sg_name}-${rule.direction}-${rule.protocol}-${rule.port}-${subnet}"
          sg_name          = sg_name
          direction        = rule.direction
          protocol         = rule.protocol
          port             = rule.port
          remote_ip_prefix = subnet
        }
      ]
    ]
  ])
}

resource "cloudru_evolution_compute_security_group" "this" {
  for_each = var.sg_rules

  project_id = var.project_id

  zone_identifier = {
    name = var.zone
  }

  name        = each.key
  description = "TF management sg"
}

resource "cloudru_evolution_compute_security_group_rule" "this" {
  for_each = {
    for rule in local.flat_rules : rule.id => rule
  }

  security_group_id = cloudru_evolution_compute_security_group.this[each.value.sg_name].id
  direction         = each.value.direction == "ingress" ? "TRAFFIC_DIRECTION_INGRESS" : "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = each.value.protocol
  port_range        = each.value.port
  remote_ip_prefix  = each.value.remote_ip_prefix
  description       = "${each.value.sg_name} rule for ${each.value.remote_ip_prefix}"
}
