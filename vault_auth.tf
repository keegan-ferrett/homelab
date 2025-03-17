# Retrieve secrets from Vault
data "vault_kv_secret_v2" "postgres" {
  mount = "core"
  name  = "postgres/admin"
}

# Deploy Ubuntu container with secrets as environment variables
resource "docker_container" "ubuntu" {
  name  = "ubuntu-secrets-container"
  image = "ubuntu:latest"

  env = [
    "DB_USER=${data.vault_kv_secret_v2.postgres.data["username"]}",
    "DB_PASS=${data.vault_kv_secret_v2.postgres.data["password"]}"
  ]

  command = ["sleep", "infinity"] # Keep the container running
}


