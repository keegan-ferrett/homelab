docker run \
  --detach \
  --name=core-traefik \
  --volume /home/keegan/traefik/acme.json:/etc/traefik/acme.json \
  --volume /home/keegan/traefik/config.yaml:/etc/traefik/traefik.yml \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --network=core-network \
  -p 443:443 \ 
  -p 80:80 \ 
  -p 8080:8080 \
  traefik:v3.2 traefik
