Homelab notes
=============
## Start virtual machine

```
make test
```

## Mounting host folder

```sh
# Inside MicroOS (as root):
mkdir -p ~/homelab
sudo mount -t 9p -o trans=virtio homelab ~/homelab
```

to make it persistent add to `/etc/fstab`

```txt
hostshare   /home/akop/homelab   9p   trans=virtio,version=9p2000.L   0   0
```


## Setup backup

Before running the backup command, you have to setup GPG encryption. 

### Step 1: Prepare encryption key

On host machine, generate a new encryption key by running `gpg --full-generate-key` with
default values. Define `backup@homelab.local` as the User ID email.

Export the generated key with `gpg --armor --export <key_ID> > backup_key.asc`, where 
`key_ID` can be found with `gpg --list-secret-keys`.

### Step 2: Install key on server

Transfer the `backup_key.asc` file to the server and import it with `gpg --import
backup_key.asc`. To confirm that the key was successfully imported, execute `gpg
--list-keys`.

### Step 3: Verify key

GPG doesn't automatically trust keys because it can't verify that the key truly belongs to
the person who claims to own it. To avoid warning message during the backup process, you 
must explicitly sign the key yourself.

Run the command `gpg --edit-key backup@homelab.local`, which brings you into an interactive
mode. In this mode, type `trust` and choose option `5 = I trust ultimately`. Don't forget
to `save` before exit.

## Troubleshooting

### Disable SELinux

If your services are failing because of permission denied err, try to disable SELinux 
by run `setenforce 0`.

### Debug combustion

Access combustion logs: `journalctl -u combustion --no-pager`

## Path to container volumes

- /home/<user>/.local/share/containers/storage/volumes/
