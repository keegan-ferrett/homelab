provider "vault" {
  address = "https://vault.keegan.boston"

    # AppRole authentication
  auth_login {
    path = "auth/system:approle/login"
    
    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}

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

variable "vault_role_id" {
  type        = string
  description = "Vault AppRole Role ID"
}

variable "vault_secret_id" {
  type        = string
  description = "Vault AppRole Secret ID"
  sensitive   = true
}
