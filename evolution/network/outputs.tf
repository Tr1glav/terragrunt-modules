output "vpcs" {
  value = {
    for k, vpc in cloudru_evolution_vpc_vpc.this : k => {
      id   = vpc.id
      name = vpc.name
    }
  }
}

output "subnets" {
  value = {
    for k, subnet in cloudru_evolution_compute_subnet.this : k => {
      id             = subnet.id
      name           = subnet.name
      vpc_id         = subnet.vpc_id
      subnet_address = subnet.subnet_address
      zone           = subnet.zone_identifier
    }
  }
}
