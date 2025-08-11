#!/bin/bash

CONTAINER_NAME=forgejo-runner
IMAGE=codeberg.org/forgejo/act_runner:latest

if podman container exists "$CONTAINER_NAME"; then
    podman stop "$CONTAINER_NAME"
    podman rm -f "$CONTAINER_NAME"
fi

podman run \
  --name "$CONTAINER_NAME" \
  --restart=always \
  --network homelab-net \
  --env-file /etc/homelab/forgejo/runner/container.env \
  -v runner-data:/data \
  $IMAGE
