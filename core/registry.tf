resource "docker_image" "registry" {
  name = "registry:3"
}

resource "docker_container" "registry" {
  name          = "registry-core"
  image         = docker_image.registry.image_id

  networks_advanced {
    name            = docker_network.core_network.id
  }

  volumes {
    host_path       = "/data/registry"
    container_path  = "/mnt/registry"
    read_only       = false
  }

  ports {
    internal = 5000
    external = 5000
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.registry-internal-router.rule"
    value = "Host(\"docker.keegan.boston\")"
  }

  labels {
    label = "traefik.http.routers.registry-internal-router.entrypoints"
    value = "web"
  }

  labels {
    label = "traefik.http.routers.registry-internal-router.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.registry-internal-router.tls.certresolver"
    value = "myresolver"
  }

  labels {
    label = "traefik.http.services.registry-service.loadbalancer.server.port"
    value = "5000"
  }
}
