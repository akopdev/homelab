#!/usr/bin/env bash
set -euo pipefail

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Run as root (sudo)." >&2
        exit 1
    fi
}

copy_service_files() {
    local src_dir="containers"
    local dst_dir="/etc/containers/systemd"

    if [[ ! -d "$src_dir" ]]; then
        echo "[ERROR] Source directory '$src_dir' not found." >&2
        return 1
    fi

    mapfile -d '' service_files < <(find "$src_dir" -type f -name "*.container" -print0)

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
        systemctl start "${filename%.container}"
    done
}

create_custom_network() {
    local src_dir="networks"
    local dst_dir="/etc/containers/systemd"

    if [[ ! -d "$src_dir" ]]; then
        echo "[ERROR] Source directory '$src_dir' not found." >&2
        return 1
    fi

    mapfile -d '' network_files < <(find "$src_dir" -type f -name "*.network" -print0)

    if [[ ${#network_files[@]} -eq 0 ]]; then
        return 0
    fi

    for network_file in "${network_files[@]}"; do
        local filename
        filename=$(basename "$network_file")
        echo "[INFO] Installing $filename -> $dst_dir"
        cp -f "$network_file" "$dst_dir/"
    done

}

init_secrets() {
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        echo -n "$value" | podman secret create --replace "$key" -
    done < "${1}"
}

require_root
init_secrets "secrets.env"
create_custom_network
copy_service_files
