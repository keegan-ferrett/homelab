import pulumi
import pulumi_docker as docker

# Create a docker image
# image = docker.Image(
#     "quay.io/minio/minio",
#     image_name="quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z",
# )

# Create a docker container using the image
container = docker.Container(
    "minio",
    image="quay.io/minio/minio:latest",
    ports=[
        docker.ContainerPortArgs(
            internal=9000,
            external=9000,
        ),
        docker.ContainerPortArgs(
            internal=9001,
            external=9001,
        ),
    ],
    labels=[
        docker.ContainerLabelArgs(
            label="traefik.enable",
            value="true",
        ),
        docker.ContainerLabelArgs(
            label="traefik.http.routers.minio-internal-router.rule",
            value='Host("minio.keegan.boston")',
        ),
        docker.ContainerLabelArgs(
            label="traefik.http.services.minio-service.loadbalancer.server.port",
            value="9001",
        ),
        docker.ContainerLabelArgs(
            label="traefik.http.routers.minio-internal-router.tls",
            value="true",
        ),
        docker.ContainerLabelArgs(
            label="traefik.http.routers.minio-internal-router.entrypoints",
            value="websecure",
        ),
        docker.ContainerLabelArgs(
            label="traefik.http.routers.minio-internal-router.tls.certresolver",
            value="myresolver",
        ),
    ],
    restart="always",
    command=["server", "/data", "--console-address", ":9001"],
)

# labels {
#   label = "traefik.http.routers.registry-internal-router.entrypoints"
#   value = "websecure"
# }

# labels {
#   label = "traefik.http.routers.registry-internal-router.tls.certresolver"
#   value = "myresolver"
# }

pulumi.export("container_id", container.id)
