resource "docker_image" "vault" {
  name = "hashicorp/vault:1.19"
}

resource "docker_container" "vault" {
  name          = "vault-core"
  image         = docker_image.vault.image_id
  network_mode  = "bridge"
  command       = [ "server" ]

  networks_advanced {
    name            = docker_network.core_network.id
  }

  capabilities {
    add             = ["IPC_LOCK"]
  }

  volumes {
    host_path       = "/data/configs/vault/config.hcl"
    container_path  = "/vault/config/config.hcl"
    read_only       = false
  }

  volumes {
    host_path       = "/data/vault/file"
    container_path  = "/vault/file"
    read_only       = false
  }

  ports {
    internal = 8200
    external = 8200
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.vault-internal-router.rule"
    value = "Host(\"vault.keegan.boston\")"
  }

  labels {
    label = "traefik.http.routers.vault-internal-router.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.vault-internal-router.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.vault-internal-router.tls.certresolver"
    value = "myresolver"
  }

  labels {
    label = "traefik.http.services.vault-service.loadbalancer.server.port"
    value = "8200"
  }
}

resource "vault_auth_backend" "approle_backend" {
  type = "approle"
  path = "approle"

  tune {
    listing_visibility = "unauth"
  }

  depends_on = [
    docker_container.vault
  ]
}
