resource "docker_image" "typesense" {
  name = "typesense/typesense:29.0"
}

resource "random_password" "typesense_key" {
  length           = 32
  special          = false
}

resource "docker_container" "typesense" {
  name          = "typesense-core"
  image         = docker_image.typesense.image_id
  network_mode  = "bridge"
  env           = [

  ]

  networks_advanced {
    name            = "e6e3be88c519"
  }

  volumes {
    host_path       = "/data/typesense"
    container_path  = "/data"
    read_only       = false
  }

  ports {
    internal = 8108
    external = 8108
  }

  command = [ "--data-dir", "/data", "--api-key=${random_password.typesense_key.result}", "--enable-cors"]

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

resource "consul_agent_service" "typesense" {
  name    = "typesense1"
  address = "192.168.88.101"
  port    = 8108
  tags    = ["db", "static"]
}
