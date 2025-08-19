# ====================
# Variables
# ====================

.EXPORT_ALL_VARIABLES:
.PHONY: clean help start setup
.DEFAULT_GOAL: help

# The path to the aarch64 UEFI firmware.
# This path is specific to macOS using Homebrew.
# Change this variable if you're on a different system.
QEMU_BIOS_PATH ?= /opt/homebrew/share/qemu/edk2-aarch64-code.fd

# MicroOS image file.
IMAGE_FILE := openSUSE-MicroOS.aarch64-ContainerHost-kvm-and-xen.qcow2

# Path to podman-systemd files
DST_DIR       := /etc/containers/systemd
SERVICE_FILES := $(shell find services -type f -name "*.container")

# ====================
# Targets
# ====================

$(IMAGE_FILE):
	@if [ ! -f "$(IMAGE_FILE)" ]; then curl -L -o $@ https://download.opensuse.org/ports/aarch64/tumbleweed/appliances/$(IMAGE_FILE); fi

combustion/wifi.conf:
	@echo "--- Setting up Wi-Fi Configuration ---"
	@read -p "Enter Wi-Fi SSID: " wifi_ssid; \
	read -s -p "Enter Wi-Fi Password: " wifi_pass; echo; \
	echo "WIFI_SSID='$$wifi_ssid'" > combustion/wifi.conf; \
	echo "WIFI_PASS='$$wifi_pass'" >> combustion/wifi.conf
	@echo "Wi-Fi configuration file created: combustion/wifi.conf"

combustion/user.conf: 
	@echo "--- Setting up System user configuration ---"
	@read -p "Enter username: " username; \
	read -s -p "Enter password for new user: " user_pass; echo;\
	user_pass_hash=`openssl passwd -1 "$$user_pass"`; \
	echo "USERNAME='$$username'" > combustion/user.conf; \
	echo "PASSWORD_HASH='$$user_pass_hash'" >> combustion/user.conf
	@echo "User configuration file created: combustion/user.conf"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

setup: combustion/wifi.conf combustion/user.conf ## Enable Wifi and add system user.

secrets: secrets.env
	@while read -r line; do \
		if [[ "$$line" =~ ^[^#].*=.* ]]; then \
			key=$$(echo "$$line" | cut -d'=' -f1); \
			value=$$(echo "$$line" | cut -d'=' -f2-); \
			echo -n "$$value" | podman secret create --replace "$$key" -; \
		fi \
	done < $<

networks:
	@cp -f $(wildcard networks/*.network) $(DST_DIR)

install: secrets networks ## Install all services.
	@cp -f $(SERVICE_FILES) $(DST_DIR);
	@systemctl daemon-reload;
	@$(foreach file, $(notdir $(SERVICE_FILES)), systemctl start $(file:.container=);)

test: $(IMAGE_FILE) setup ## Launch virtual machine with Qemu
	qemu-system-aarch64 \
				-machine virt \
				-cpu cortex-a72 \
				-m 2048 \
				-nographic \
				-bios $(QEMU_BIOS_PATH) \
				-drive if=virtio,file=$(IMAGE_FILE),format=qcow2 \
				-netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::80-:80 \
				-device virtio-net-pci,netdev=net0 \
				-fsdev local,id=fsdev0,path=.,security_model=none \
				-device virtio-9p-pci,fsdev=fsdev0,mount_tag=hostshare \
				-fw_cfg name=opt/org.opensuse.combustion/script,file=combustion/script \
				-fw_cfg name=opt/org.opensuse.combustion/wifi.conf,file=combustion/wifi.conf \
				-fw_cfg name=opt/org.opensuse.combustion/user.conf,file=combustion/user.conf


clean: ## Clean up temp files.
	@rm -f $(IMAGE_FILE) combustion/*.conf
