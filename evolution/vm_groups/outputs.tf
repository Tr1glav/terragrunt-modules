output "external_ips" {
  value = {
    for vm_name, vm_config in local.vms :
    vm_name => cloudru_evolution_compute_external_ip.this[vm_name].ip_address
    if vm_config.external_ip == true
  }
}
