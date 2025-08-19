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
COMBUSTION_FILE := combustion.img

# Path to podman quadlet files
DST_DIR       := $(HOME)/.config/containers/systemd
QUADLET_DIR 	:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/quadlet

# ====================
# Targets
# ====================

$(IMAGE_FILE):
	@if [ ! -f "$(IMAGE_FILE)" ]; then curl -L -o $@ https://download.opensuse.org/ports/aarch64/tumbleweed/appliances/$(IMAGE_FILE); fi

$(DST_DIR):
	@mkdir -p $@

combustion/user.conf: 
	@echo "--- Setting up System user configuration ---"
	@read -p "Enter username: " username; \
	read -s -p "Enter password for new user: " user_pass; echo;\
	user_pass_hash=`openssl passwd -1 "$$user_pass"`; \
	echo "USERNAME='$$username'" > combustion/user.conf; \
	echo "PASSWORD_HASH='$$user_pass_hash'" >> combustion/user.conf
	@echo "User configuration file created: combustion/user.conf"

$(COMBUSTION_FILE): combustion/user.conf
	@dd if=/dev/zero of=$@ bs=1m count=4
	@mkfs.vfat -n COMBUSTION $@
	@mcopy -i $@ -s combustion ::

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

secrets: secrets.env
	@while read -r line; do \
		if [[ "$$line" =~ ^[^#].*=.* ]]; then \
			key=$$(echo "$$line" | cut -d'=' -f1); \
			value=$$(echo "$$line" | cut -d'=' -f2-); \
			echo -n "$$value" | podman secret create --replace "$$key" -; \
		fi \
	done < $<

install: secrets $(DST_DIR) ## Install all services.
	@ln -sfn $(QUADLET_DIR) $(DST_DIR)
	@systemctl --user daemon-reload

test: $(COMBUSTION_FILE) $(IMAGE_FILE)  ## Launch virtual machine with Qemu
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
				-drive file=$(COMBUSTION_FILE),format=raw,if=virtio


clean: ## Clean up temp files.
	@rm -f $(IMAGE_FILE) $(COMBUSTION_FILE) combustion/*.conf
