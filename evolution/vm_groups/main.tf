terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
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

resource "cloudru_evolution_compute_disk" "boot_disk" {
  for_each   = var.vms
  project_id = var.project_id
  name       = "${each.key}-root"

  disk_type_identifier = {
    id = local.cloudru_disk_type.id
  }

  bootable = true
  size     = each.value.disk

  image_id = local.images["Ubuntu 24.04"].id

  zone_identifier = {
    name = local.subnet_by_cidr[each.value.subnet].zone.name
  }
}

resource "cloudru_evolution_compute_interface" "this" {
  for_each   = var.vms
  project_id = var.project_id
  name       = "${each.key}-eth0"
  subnet_id  = local.subnet_by_cidr[each.value.subnet].id
  ip_address = each.value.ip
  type       = "INTERFACE_TYPE_REGULAR"

  zone_identifier = {
    name = local.subnet_by_cidr[each.value.subnet].zone.name
  }

  interface_security_enabled = !strcontains(each.key, "router")

  security_groups_identifiers = {
    value = !strcontains(each.key, "router") ? concat(
      [{ id = local.sg["default-${local.zone_name_to_short_name[local.subnet_by_cidr[each.value.subnet].zone.name]}"].id }],
      length(try(each.value.sg, [])) > 0 ? [
        for sg_name in each.value.sg : {
          id = local.sg["${sg_name}-${local.zone_name_to_short_name[local.subnet_by_cidr[each.value.subnet].zone.name]}"].id
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
    name = local.subnet_by_cidr[each.value.subnet].zone.name
  }

  flavor_identifier = {
    name = local.flavors[each.key].name
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
    name = local.subnet_by_cidr[each.value.subnet].zone.name
  }

  name = "${each.key}-external-ip"
}
