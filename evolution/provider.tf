generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.0"
    }
  }
}
provider "cloudru" {
  project_id  = data.vault_kv_secret_v2.secrets.data["project_id"]
  customer_id = data.vault_kv_secret_v2.secrets.data["customer_id"]
  auth_key_id = data.vault_kv_secret_v2.secrets.data["IAM_CLIENT_ID"]
  auth_secret = data.vault_kv_secret_v2.secrets.data["IAM_CLIENT_SECRET"]
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