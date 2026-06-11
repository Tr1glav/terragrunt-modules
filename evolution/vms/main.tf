resource "cloudru_evolution_compute_disk" "boot_disk" {
  for_each   = var.vms
  project_id = var.project_id
  name       = "${each.key}-root"

  disk_type_identifier = {
    id = var.disk_type_id
  }

  bootable = true
  size     = each.value.disk

  image_id = var.image_id

  zone_identifier = {
    name = var.zone
  }
}

resource "cloudru_evolution_compute_interface" "this" {
  for_each   = var.vms
  project_id = var.project_id
  name       = "${each.key}-eth0"
  subnet_id  = var.subnet_id
  ip_address = each.value.ip
  type       = "INTERFACE_TYPE_REGULAR"

  zone_identifier = {
    name = var.zone
  }

  interface_security_enabled = !strcontains(each.key, "router")

  security_groups_identifiers = {
    value = !strcontains(each.key, "router") ? concat(
      [{ id = var.security_groups["default"] }],
      length(try(each.value.sg, [])) > 0 ? [
        for sg_name in each.value.sg : {
          id = var.security_groups[sg_name]
        }
      ] : []
    ) : []
  }
}

resource "cloudru_evolution_compute_vm" "this" {
  for_each   = var.vms
  project_id = var.project_id

  name = each.key

  zone_identifier = {
    name = var.zone
  }

  flavor_identifier = {
    name = var.flavors[each.key].name
  }

  disk_identifiers = [
    {
      disk_id = cloudru_evolution_compute_disk.boot_disk[each.key].id
    }
  ]

  network_interfaces = [
    {
      interface_id = cloudru_evolution_compute_interface.this[each.key].id
    }
  ]

  image_metadata = {
    name = {
      string_value = var.username
    }
    hostname = {
      string_value = each.key
    }
    public_key = {
      string_value = var.public_key
    }
  }

  depends_on = [cloudru_evolution_compute_interface.this]
}

resource "cloudru_evolution_compute_external_ip" "this" {
  for_each = {
    for k, v in var.vms : k => v if v.external_ip == true
  }

  interface_id = cloudru_evolution_compute_interface.this[each.key].id
  project_id   = var.project_id

  zone_identifier = {
    name = var.zone
  }

  name = "${each.key}-external-ip"
}
