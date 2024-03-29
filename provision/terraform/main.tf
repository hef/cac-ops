terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.23.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

provider "sops" {}

data "sops_file" "secrets" {
  source_file = "secrets.sops.yaml"
}

provider "cloudflare" {
  version = "3.15.0"
  email   = data.sops_file.secrets.data["cloudflare_email"]
  api_token = data.sops_file.secrets.data["cloudflare_api_token"]
}

data "cloudflare_zones" "domain" {
  filter {
    name = "hef.wtf"
  }
}

resource "cloudflare_zone_settings_override" "settings" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
}

resource "cloudflare_authenticated_origin_pulls" "main" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  enabled = true
}
