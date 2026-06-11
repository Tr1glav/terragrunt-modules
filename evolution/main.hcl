generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.2"
    }
  }
}
provider "cloudru" {
  project_id   = var.project_id
  customer_id  = var.customer_id
  auth_key_id  = var.auth_key_id
  auth_secret  = var.auth_secret
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
EOF
}