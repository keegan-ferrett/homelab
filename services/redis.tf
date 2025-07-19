resource "docker_image" "redis" {
  name = "redis:8.0"
}

resource "docker_container" "redis" {
  name          = "redis-core"
  image         = docker_image.redis.image_id
  network_mode  = "bridge"
  env           = [
  ]

  networks_advanced {
    name            = "e6e3be88c519"
  }

  volumes {
    host_path       = "/data/redis"
    container_path  = "/data"
    read_only       = false
  }

  ports {
    internal = 6379
    external = 6379
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.tcp.routers.redis-router.rule"
    value = "HostSNI(\"redis.keegan.boston\")"
  }
}

resource "consul_agent_service" "redis1" {
  name    = "redis1"
  address = "192.168.88.101"
  port    = 6379
  tags    = ["db", "static"]
}

