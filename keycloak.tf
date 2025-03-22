resource "docker_image" "keycloak" {
  name = "quay.io/keycloak/keycloak:26.1.0"
}

data "vault_kv_secret_v2" "keycloak" {
  mount = "core"
  name  = "keycloak/admin"
}

data "vault_kv_secret_v2" "keycloak_db" {
  mount = "core"
  name  = "keycloak/postgres"
}

resource "docker_container" "keycloak" {
  name          = "keycloak-app"
  image         = docker_image.keycloak.image_id
  network_mode  = "bridge"
  command       = [ "start" ]
  env           = [
    "KC_PROXY_ADDRESS_FORWARDING=true",
    "KC_PROXY_HEADERS=xforwarded",
    "KC_HOSTNAME_STRICT=false",
    "KC_HOSTNAME=auth.example.com",
    "KC_PROXY=edge",
    "KC_HTTP_ENABLED=true",
    "KC_BOOTSTRAP_ADMIN_USERNAME=${data.vault_kv_secret_v2.keycloak.data["username"]}",
    "KC_BOOTSTRAP_ADMIN_PASSWORD=${data.vault_kv_secret_v2.keycloak.data["password"]}",
    "KC_HOSTNAME=auth.keegan.boston",
    "KC_HOSTNAME_STRICT=false",
    "KC_PROXY=passthrough",
    "KC_DB=postgres",
    "KC_DB_URL_HOST=${data.vault_kv_secret_v2.keycloak_db.data["host"]}",
    "KC_DB_USERNAME=${data.vault_kv_secret_v2.keycloak_db.data["username"]}",
    "KC_DB_PASSWORD=${data.vault_kv_secret_v2.keycloak_db.data["password"]}",
    "KC_DB_NAME=${data.vault_kv_secret_v2.keycloak_db.data["name"]}"
  ]

  networks_advanced {
    name        = docker_network.core_network.id
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.keycloak-internal-router.rule"
    value = "Host(\"auth.keegan.boston\")"
  }

  labels {
    label = "traefik.http.routers.keycloak-internal-router.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.keycloak-internal-router.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.keycloak-internal-router.tls.certresolver"
    value = "myresolver"
  }

  labels {
    label = "traefik.http.services.keycloak-service.loadbalancer.server.port"
    value = "8080"
  }

}
