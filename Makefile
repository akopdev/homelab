.EXPORT_ALL_VARIABLES: ; 
.PHONY: all
.DEFAULT_GOAL: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

start: ## Launch virtual machine with Qemu
	qemu-system-aarch64 \
		-machine virt \
		-cpu cortex-a72 \
		-m 2048 \
		-nographic \
		-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
		-drive if=virtio,file=openSUSE-MicroOS.aarch64-ContainerHost-kvm-and-xen.qcow2,format=qcow2 \
		-netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::3000-:3000 \
		-device virtio-net-pci,netdev=net0 \
		-fsdev local,id=fsdev0,path=homelab,security_model=none \
		-device virtio-9p-pci,fsdev=fsdev0,mount_tag=hostshare
