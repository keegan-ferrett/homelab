resource "docker_image" "typesense" {
  name = "typesense/typesense:28.0"
}

data "vault_kv_secret_v2" "typesense" {
  mount = "core"
  name  = "typesense/admin"
}

resource "docker_container" "typesense" {
  name          = "typesense-core"
  image         = docker_image.typesense.image_id
  network_mode  = "bridge"
  command       = [ "--data-dir", "/data", "--api-key=${data.vault_kv_secret_v2.typesense.data["key"]}", "--enable-cors" ]

  networks_advanced {
    name        = docker_network.core_network.id
  }

  volumes {
    host_path       = "/data/typesense"
    container_path  = "/data"
    read_only       = false
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.typesense-internal-router.rule"
    value = "Host(\"typesense.keegan.boston\")"
  }

  labels {
    label = "traefik.http.routers.typesense-internal-router.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.typesense-internal-router.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.typesense-internal-router.tls.certresolver"
    value = "myresolver"
  }


  labels {
    label = "traefik.http.services.typesense-service.loadbalancer.server.port"
    value = "8108"
  }

}
