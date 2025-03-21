resource "docker_image" "cassandra" {
  name = "cassandra:5.0"
}

resource "docker_container" "cassandra" {
  name          = "cassandra-core"
  image         = docker_image.cassandra.image_id
  network_mode  = "bridge"

  networks_advanced {
    name            = docker_network.core_network.id
  }

  volumes {
    host_path       = "/data/cassandra"
    container_path  = "/var/lib/cassandra"
    read_only       = false
  }

  ports {
    internal = 7000
    external = 7000
  }
}
