terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.6.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.6.3"
    }
  }
}

provider "sops" {}

data "sops_file" "secrets" {
  source_file = "secrets.sops.yaml"
}

provider "cloudflare" {
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