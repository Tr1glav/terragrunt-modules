output "vpc_id" {
  value = cloudru_evolution_vpc_vpc.this.id
}

output "subnet_id" {
  value = cloudru_evolution_compute_subnet.this.id
}
