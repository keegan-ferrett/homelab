resource "docker_image" "rabbitmq" {
  name = "rabbitmq:4.1-management"
}

resource "random_password" "rabbitmq" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_=+?"
}

resource "docker_container" "rabbitmq" {
  name          = "rabbitmq-core"
  image         = docker_image.rabbitmq.image_id
  network_mode  = "bridge"
  env           = [
    "RABBITMQ_DEFAULT_USER=user",
    "RABBITMQ_DEFAULT_PASS=${random_password.rabbitmq.result}"
  ]

  networks_advanced {
    name            = "e6e3be88c519"
  }

  volumes {
    host_path       = "/data/rabbitmq"
    container_path  = "/var/lib/rabbitmq"
    read_only       = false
  }

  ports {
    internal = 5672
    external = 5672
  }

  ports {
    internal = 15672
    external = 15672
  }
}

resource "consul_agent_service" "rabbitmq" {
  name    = "rabbitmq1"
  address = "192.168.88.101"
  port    = 5672
  tags    = ["tasks", "static"]
}

resource "vault_kv_secret_v2" "admin_rabbitmq" {
  mount                      = vault_mount.postgres_pass.path
  name                       = "admin/rabbitmq"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
    {
      username  = "admin" 
      password  = random_password.rabbitmq.result
    }
  )

  custom_metadata {

  }
}
