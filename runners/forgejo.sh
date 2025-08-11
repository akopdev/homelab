#!/bin/bash

run_container codeberg.org/forgejo/forgejo:1.21 \
  -p 3000:3000 \
  -v forgejo-data:/var/lib/gitea \
  -v forgejo-config:/etc/gitea \
  -v forgejo-ssh:/data/ssh
