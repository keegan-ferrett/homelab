provider "vault" {
  address = "https://vault.keegan.boston"
}

resource "vault_auth_backend_login" "approle" {
  path      = "auth/system:core/login"

  parameters = {
    role_id   = var.vault_role_id
    secret_id = var.vault_secret_id
  }
}

data "vault_kv_secret_v2" "myapp_secrets" {
  mount = "secret"
  name  = "myapp"

  depends_on = [vault_auth_backend_login.approle]
}

resource "docker_container" "ubuntu" {
  name  = "ubuntu-secrets-container"
  image = "ubuntu:latest"

  env = [
    "DB_USER=${data.vault_kv_secret_v2.myapp_secrets.data["DB_USER"]}",
    "DB_PASS=${data.vault_kv_secret_v2.myapp_secrets.data["DB_PASS"]}"
  ]

  command = ["sleep", "infinity"] # Keep the container running for testing
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
