terraform {
  cloud {
    organization = "ferrett-homelab"

    workspaces {
      name = "homelab-services"
    }
  }

  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }

    vault = {
      source = "hashicorp/vault"
      version = "5.1.0"
    }
  }
}

provider "vault" {
  address = "http://192.168.88.101:8200"
  skip_child_token = true
}

provider "random" {
  # Configuration options
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_mount" "kvv2" {
  path        = "my-kvv2"
  type        = "kv"
  options     = { version = "2" }
}

resource "vault_kv_secret_v2" "example" {
  mount                      = vault_mount.kvv2.path
  name                       = "secret"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
    {
      zip       = "zap",
      foo       = "bar",
      passowrd  = random_password.password.result
    }
  )

  custom_metadata {

  }
}
