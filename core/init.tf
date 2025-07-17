terraform {
  cloud {
    organization = "ferrett-homelab"

    workspaces {
      name = "homelab:core"
    }
  }

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }

    vault = {
      source = "hashicorp/vault"
      version = "4.7.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# provider "vault" {
#   address               = "https://vault.keegan.boston"
#   token_name             = ""
#   skip_child_token       = true
#   max_lease_ttl_seconds  = 0
#
#   # AppRole authentication
#   auth_login {
#     path = "auth/system:approle/login"
#     
#     parameters = {
#       role_id   = var.vault_role_id
#       secret_id = var.vault_secret_id
#     }
#   }
# }

resource "docker_network" "core_network" {
  name = "network-core"
}

# variable "vault_role_id" {
#   type        = string
#   description = "Vault AppRole Role ID"
# }
#
# variable "vault_secret_id" {
#   type        = string
#   description = "Vault AppRole Secret ID"
#   sensitive   = true
# }
