data "cloudru_evolution_compute_disk_type_collection" "disk_type" {
  project_id = var.project_id
}
data "cloudru_evolution_compute_flavor_collection" "flavor_collection" {
  project_id = var.project_id
}
data "cloudru_evolution_compute_image_collection" "image_collection" {
  project_id = var.project_id
}
data "cloudru_evolution_vpc_vpc_collection" "datasource_vpc" {
  project_id = var.project_id
  page_size  = 1000
  filter     = "name in ['evo_vpc']"
}
data "cloudru_evolution_compute_security_group_collection" "datasource_security_group" {
  project_id = var.project_id
  page_size  = 1000
}

data "cloudru_evolution_compute_subnet_collection" "datasource_subnet" {
  project_id = var.project_id
}

locals {
  cloudru_disk_types = [
    for s in data.cloudru_evolution_compute_disk_type_collection.disk_type.disk_types : s if s.name == "SSD"
  ]
  cloudru_disk_type = local.cloudru_disk_types.0

  flavors = {
    for name, config in var.vms : name =>
    try(one([
      for s in data.cloudru_evolution_compute_flavor_collection.flavor_collection.flavors :
      s if s.name == "${config.flavor_type}-${config.cpu}-${config.ram}"
    ]), null)
  }
  sg = try(data.cloudru_evolution_compute_security_group.resource_security_group.flavors, [])
  required_images = [
    var.required_image
  ]
  images = {
    for image_name in local.required_images : image_name =>
    try(one([
      for s in data.cloudru_evolution_compute_image_collection.image_collection.images :
      s if s.display_name == image_name
    ]), null)
  }
}


output "data-subnet" {
  value = data.cloudru_evolution_compute_subnet_collection.datasource_subnet.subnets[0].subnet_address
}