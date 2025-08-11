#!/bin/bash

CONTAINER_NAME=postgres
IMAGE=docker.io/library/postgres:15-alpine
PORT=5432

if podman container exists "$CONTAINER_NAME"; then
    podman stop "$CONTAINER_NAME"
    podman rm -f "$CONTAINER_NAME"
fi

podman run \
  --name "$CONTAINER_NAME" \
  --restart=always \
  --network homelab-net \
  -p $PORT:5432 \
  --env-file /etc/homelab/postgres/container.env \
  -v postgres-data:/var/lib/postgresql/data \
  $IMAGE
