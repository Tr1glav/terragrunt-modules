output "security_groups" {
  value = {
    for k, sg in cloudru_evolution_compute_security_group.this : k => sg.id
  }
}
