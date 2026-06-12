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

variable "zone" {
  type = string
}

variable "vms" {
  type = any
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
