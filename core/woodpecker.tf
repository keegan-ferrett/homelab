variable "GITHUB_CLIENT" {
  type = string
}

variable "GITHUB_SECRET" {
  type = string
}

resource "random_password" "woodpecker" {
  length           = 16
  special          = false
}

resource "docker_image" "woodpecker_s" {
  name = "woodpeckerci/woodpecker-server:v3"
}

resource "docker_image" "woodpecker_a" {
  name = "woodpeckerci/woodpecker-agent:v3"
}

resource "docker_container" "woodpecker_server" {
  name          = "woodpecker-server-core"
  image         = docker_image.woodpecker_s.image_id

  env           = [
    "WOODPECKER_OPEN=false",
    "WOODPECKER_HOST=https://woodpecker.keegan.boston",
    "WOODPECKER_GITHUB=true",
    "WOODPECKER_GITHUB_CLIENT=${var.GITHUB_CLIENT}",
    "WOODPECKER_GITHUB_SECRET=${var.GITHUB_SECRET}",
    "WOODPECKER_AGENT_SECRET=${random_password.woodpecker.result}",
    "WOODPECKER_ADMIN=keegan-ferrett",
    "WOODPECKER_PLUGINS_PRIVILEGED=woodpeckerci/plugin-docker-buildx:latest"
  ]


  networks_advanced {
    name            = docker_network.core_network.id
  }

  volumes {
    host_path       = "/data/woodpecker"
    container_path  = "/var/lib/woodpecker"
    read_only       = false
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.woodpecker-internal-router.rule"
    value = "Host(\"woodpecker.keegan.boston\")"
  }

  labels {
    label = "traefik.http.routers.woodpecker-internal-router.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.woodpecker-internal-router.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.woodpecker-internal-router.tls.certresolver"
    value = "myresolver"
  }

  labels {
    label = "traefik.http.services.woodpecker-service.loadbalancer.server.port"
    value = "8000"
  }
}

resource "docker_container" "woodpecker_agent" {
  name          = "woodpecker-agent-core"
  image         = docker_image.woodpecker_a.image_id

  networks_advanced {
    name            = docker_network.core_network.id
  }

  env           = [
    "WOODPECKER_SERVER=woodpecker-server-core:9000",
    "WOODPECKER_AGENT_SECRET=${random_password.woodpecker.result}"
  ]


  volumes {
    host_path       = "/var/run/docker.sock"
    container_path  = "/var/run/docker.sock"
    read_only       = false
  }
}

