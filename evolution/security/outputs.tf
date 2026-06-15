output "security_groups" {
  value = {
    for k, sg in cloudru_evolution_compute_security_group.this : k => {
      id   = sg.id
      zone = sg.zone_identifier
    }
  }
}

output "zones" {
  value = local.all_zones
}
