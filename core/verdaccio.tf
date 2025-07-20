resource "docker_image" "verdaccio" {
  name = "verdaccio/verdaccio:6.1"
}

resource "docker_container" "verdaccio" {
  name          = "verdaccio-core"
  image         = docker_image.verdaccio.image_id

  networks_advanced {
    name            = docker_network.core_network.id
  }

  # volumes {
  #   host_path       = "/data/verdaccio"
  #   container_path  = "/verdaccio/storage"
  #   read_only       = false
  # }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.verdaccio-internal-router.rule"
    value = "Host(\"npm.keegan.boston\")"
  }

  labels {
    label = "traefik.http.routers.verdaccio-internal-router.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.verdaccio-internal-router.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.verdaccio-internal-router.tls.certresolver"
    value = "myresolver"
  }

  labels {
    label = "traefik.http.services.verdaccio-service.loadbalancer.server.port"
    value = "4873"
  }
}
