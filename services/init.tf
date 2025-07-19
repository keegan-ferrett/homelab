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

    consul = {
      source = "hashicorp/consul"
      version = "2.22.0"
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

provider "consul" {
  address    = "192.168.88.101:8500"
  datacenter = "dc1"
}

provider "random" {
  # Configuration options
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
      passowrd  = random_password.postgres_password.result
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
    "POSTGRES_PASSWORD=${random_password.postgres_password.result}"
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
    value = "HostSNI(\"postgres.keegan.boston\")"
  }
}

resource "consul_service" "postgres" {
  name    = "postgres"
  node    = "node0"
  address = "192.168.88.101"
  port    = 5432
  tags    = ["db", "static"]

  check {
    check_id        = "service:postgres"
    name            = "Postgres TCP Health Check"
    tcp             = "192.168.88.101:5432"
    interval        = "10s"
    timeout         = "1s"
    tls_skip_verify = true
    deregister_critical_service_after = "0"
  }
}
