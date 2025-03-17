provider "vault" {
  address = "https://vault.keegan.boston"
  token   = vault_approle_auth_backend_login.approle.token
}

# Authenticate with Vault using AppRole
resource "vault_approle_auth_backend_login" "approle" {
  role_id   = var.vault_role_id
  secret_id = var.vault_secret_id
}

# Retrieve secrets from Vault
data "vault_kv_secret_v2" "myapp_secrets" {
  mount = "core"
  name  = "core"

  depends_on = [vault_approle_auth_backend_login.approle]
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
