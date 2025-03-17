terraform {
  cloud {
    organization = "ferrett-homelab"

    workspaces {
      name = "homelab"
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

resource "docker_network" "core_network" {
  name = "network-core"
}

