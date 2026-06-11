variable "project_id" {
  type = string
}

variable "name" {
  type    = string
  default = "evo_vpc"
}

variable "description" {
  type    = string
  default = "TF management vpc"
}

variable "subnet_name" {
  type    = string
  default = "evo_sg_subnet"
}

variable "subnet_address" {
  type    = string
  default = "172.18.1.0/24"
}

variable "zone" {
  type = string
  default = inputs.cloudru_default_az
}
