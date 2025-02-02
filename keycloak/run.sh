if [[ ! -v KC_USERNAME ]]; then
  echo "KC_USERNAME" is not set
  exit 1
fi

if [[ ! -v KC_PASSWORD ]]; then
  echo "KC_PASSWORD" is not set
  exit 1
fi

docker run \
  -d \
  --name app-keycloak \
  -e KC_PROXY_ADDRESS_FORWARDING=true \
  -e KC_PROXY_HEADERS=xforwarded \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HOSTNAME=auth.example.com \
  -e KC_PROXY=edge \
  -e KC_HTTP_ENABLED=true \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=$KC_USERNAME \
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=$KC_PASSWORD \
  -e KC_HOSTNAME=auth.keegan.boston \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_PROXY=passthrough \
  -e KC_DB_URL_HOST=192.168.0.39 \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=1UJIdTndipf1PZJFIBcGwyEiezm \
  -e KC_DB_NAME=keycloak \
  -e KC_DB=postgres \
  --network core-network \
  --label traefik.enable=true \
  --label "traefik.http.routers.keycloak-router.rule=Host(\"auth.keegan.boston\")" \
  --label traefik.http.services.keycloak-service.loadbalancer.server.port=8080 \
  --label traefik.http.routers.keycloak-router.entrypoints=websecure \
  --label traefik.http.routers.keycloak-router.tls=true \
  --label traefik.http.routers.keycloak-router.tls.certresolver=myresolver \
  quay.io/keycloak/keycloak:26.1.0 \
  start

