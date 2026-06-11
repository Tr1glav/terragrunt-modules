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
