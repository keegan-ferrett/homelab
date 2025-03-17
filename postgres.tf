resource "docker_image" "postgres" {
  name = "postgres:17.2"
}

data "vault_kv_secret_v2" "postgres" {
  mount = "core"
  name  = "postgres/admin"
}

resource "docker_container" "postgres" {
  name          = "postgres-core"
  image         = docker_image.postgres.image_id
  network_mode  = "bridge"
  env           = [
    "POSTGRES_USER=${data.vault_kv_secret_v2.postgres.data["username"]}",
    "POSTGRES_PASSWORD=${data.vault_kv_secret_v2.postgres.data["password"]}"
  ]

  networks_advanced {
    name            = docker_network.core_network.id
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
