#!/bin/bash

CONTAINER_NAME=forgejo
IMAGE=codeberg.org/forgejo/forgejo:1.21
PORT=3000
SSH_PORT=2222

if podman container exists "$CONTAINER_NAME"; then
    podman stop "$CONTAINER_NAME"
    podman rm -f "$CONTAINER_NAME"
fi

podman run \
  --name "$CONTAINER_NAME" \
  --restart=always \
  --network homelab-net \
  -p ${PORT}:3000 \
  -p ${SSH_PORT}:22 \
  --env-file /etc/homelab/forgejo/container.env \
  -v forgejo-data:/var/lib/gitea \
  -v forgejo-config:/etc/gitea \
  -v forgejo-ssh:/data/ssh \
  $IMAGE
