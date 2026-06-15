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

variable "description" {
  type    = string
  default = "TF management vpc"
}

variable "subnets" {
  type = map(map(map(string)))
  description = <<-EOT
    Structure:
    {
      "<vpc_name>" = {
        "<subnet_name>" = {
          "subnet" = "<CIDR>"
          "zone"   = "<zone_name>"
        }
      }
    }
  EOT
}
