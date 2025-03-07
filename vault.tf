resource "docker_image" "vault" {
  name = "hashicorp/vault:1.19"
}

resource "docker_container" "vault" {
  name          = "vault-core"
  image         = docker_image.vault.image_id
  network_mode  = "bridge"
  command       = [ "server" ]

  volumes {
    host_path       = "${path.cwd}/core/vault/config.hcl"
    container_path  = "/vault/config/config.hcl"
    read_only       = false
  }

  volumes {
    host_path       = "${path.cwd}/vault"
    container_path  = "/vault/file"
    read_only       = false
  }

  ports {
    internal = 8200
    external = 8200
  }
}
