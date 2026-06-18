variable "project_id" {
  type = string
}

variable "customer_id" {
  type = string
}

variable "auth_key_id" {
  type = string
}

variable "auth_secret" {
  type = string
}

variable "vm_groups" {
  type = map(object({
    external_ip = bool
    subnet      = string
    cpu         = number
    ram         = number
    disk        = number
    flavor_type = string
    sg          = list(string)
    vms = map(object({
      ip = string
    }))
  }))
}

variable "security_groups" {
  type    = map(string)
  default = {}
}

variable "username" {
  type = string
}

variable "public_key" {
  type = string
}

variable "required_image" {
  description = "default image for vms"
  type        = string
  default     = "Ubuntu 24.04"
}