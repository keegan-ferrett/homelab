provider "vault" {
  address = "https://vault.keegan.boston"
}

# Authenticate with Vault using AppRole
resource "vault_approle_auth_backend_login" "approle" {
  role_id   = var.vault_role_id
  secret_id = var.vault_secret_id
}

# Retrieve secrets from Vault
data "vault_kv_secret_v2" "myapp_secrets" {
  mount = "core/postgres"
  name  = "core"

  depends_on = [vault_approle_auth_backend_login.approle]
}

# Deploy Ubuntu container with secrets as environment variables
resource "docker_container" "ubuntu" {
  name  = "ubuntu-secrets-container"
  image = "ubuntu:latest"

  env = [
    "DB_USER=${data.vault_kv_secret_v2.admin.data["data"]["DB_USER"]}",
    "DB_PASS=${data.vault_kv_secret_v2.admin.data["data"]["DB_PASS"]}"
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
