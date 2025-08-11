#!/bin/bash

# PostgreSQL
sudo cp /etc/homelab/postgres/container.service /etc/systemd/system/postgres-container.service

# Forgejo
sudo cp /etc/homelab/forgejo/container.service /etc/systemd/system/forgejo-container.service

# Forgejo Actions Runner
sudo cp /etc/homelab/forgejo/runner/container.service /etc/systemd/system/runner-container.service


NETWORK_NAME="homelab-net"

if ! podman network exists "$NETWORK_NAME"; then
  echo "Creating network '$NETWORK_NAME'..."
  podman network create "$NETWORK_NAME" && echo "Network created."
fi

# Reload and enable
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

sudo systemctl enable --now postgres-container.service
sudo systemctl enable --now forgejo-container.service
sudo systemctl enable --now runner-container.service

