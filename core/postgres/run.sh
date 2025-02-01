if [[ ! -v PG_USERNAME ]]; then
  echo "PG_USERNAME" is not set
  exit 1
fi

if [[ ! -v PG_PASSWORD ]]; then
  echo "PG_PASSWORD" is not set
  exit 1
fi

docker run -d \
  --name=core-postgres \
  --volume /data/postgres:/var/lib/postgresql/data \
  --env=POSTGRES_PASSWORD=$PG_USERNAME \
  --env=POSTGRES_USER=$PG_PASSWORD \
  --network core-network \
  -p 5432:5432 \
  --restart=always \
  postgres:17.2 \   
  postgres
