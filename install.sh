#!/usr/bin/env bash
set -euo pipefail

NETWORK_NAME="homelab-net"

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Run as root (sudo)." >&2
        exit 1
    fi
}

copy_service_files() {
    local src_dir="services"
    local dst_dir="/etc/systemd/system"

    if [[ ! -d "$src_dir" ]]; then
        echo "[ERROR] Source directory '$src_dir' not found." >&2
        return 1
    fi

    mapfile -d '' service_files < <(find "$src_dir" -type f -name "*.service" -print0)

    if [[ ${#service_files[@]} -eq 0 ]]; then
        echo "[WARN] No .service files found in '$src_dir'."
        return 0
    fi

    for service_file in "${service_files[@]}"; do
        local filename
        filename=$(basename "$service_file")
        echo "[INFO] Installing $filename -> $dst_dir"
        cp -f "$service_file" "$dst_dir/"
    done

    echo "[INFO] Reloading systemd daemon..."
    systemctl daemon-reload

    for service_file in "${service_files[@]}"; do
        local filename
        filename=$(basename "$service_file")
        echo "[INFO] Enabling & starting $filename"
        systemctl enable --now "$filename"
    done
}

create_custom_network() {
    local net_name="$1"
    if ! podman network exists "$net_name" &>/dev/null; then
        echo "[INFO] Creating network '$net_name'..."
        podman network create "$net_name"
        echo "[INFO] Network created."
    else
        echo "[INFO] Network '$net_name' already exists."
    fi
}

require_root
create_custom_network "$NETWORK_NAME"
copy_service_files
