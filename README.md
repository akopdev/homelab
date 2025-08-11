Homelab notes
=============
## Start virtual machine

```
make start
```

## Mounting host folder

```sh
# Inside MicroOS (as root):
mkdir -p /etc/homelab
mount -t 9p -o trans=virtio hostshare /etc/homelab
```

to make it persistent add to `/etc/fstab`

```txt
hostshare   /etc/homelab   9p   trans=virtio,version=9p2000.L   0   0
```

## Troubleshooting

If your services are failing because of permission denied err, try to disable SELinux 
by run `setenforce 0`.
