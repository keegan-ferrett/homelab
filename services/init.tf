terraform {
  cloud {
    organization = "ferrett-homelab"

    workspaces {
      name = "homelab-services"
    }
  }

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    
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

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "vault" {
  address = "http://192.168.88.101:8200"
  skip_child_token = true
}

provider "random" {
  # Configuration options
}

resource "docker_network" "core_network" {
  name = "network-core"
}

resource "random_password" "postgres_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_=+?"
}

resource "vault_mount" "postgres_pass" {
  path        = "services"
  type        = "kv"
  options     = { version = "2" }
}

resource "vault_kv_secret_v2" "admin_postgress" {
  mount                      = vault_mount.postgres_pass.path
  name                       = "admin/postgres"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
    {
      username  = "admin"
      passowrd  = random_password.postgres_pass.result
    }
  )

  custom_metadata {

  }
}

resource "docker_image" "postgres" {
  name = "postgres:17.2"
}

resource "docker_container" "postgres" {
  name          = "postgres-core"
  image         = docker_image.postgres.image_id
  network_mode  = "bridge"
  env           = [
    "POSTGRES_USER=admin",
    "POSTGRES_PASSWORD=${vault_mount.postgres_pass.path}"
  ]

  networks_advanced {
    name            = "e6e3be88c519"
  }

  volumes {
    host_path       = "/data/postgres"
    container_path  = "/var/lib/postgresql/data"
    read_only       = false
  }

  ports {
    internal = 5432
    external = 5432
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.tcp.routers.postgres-router.rule"
    value = "Host(\"postgres.keegan.boston\")"
  }

}
