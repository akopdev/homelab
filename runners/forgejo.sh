#!/bin/bash

run_container codeberg.org/forgejo/forgejo:1.21 \
  -p 3000:3000 \
  -v forgejo-data:/var/lib/gitea \
  -v forgejo-config:/etc/gitea \
  -e  FORGEJO__database__DB_TYPE=postgres \
  -e  FORGEJO__database__HOST=postgres:5432 \
  -e  FORGEJO__database__NAME=forgejo \
  -e  FORGEJO__database__USER=forgejo \
  -e  FORGEJO__database__PASSWD=changeme \
  -e  FORGEJO__server__ROOT_URL=http://localhost:3000/ \
  -e  FORGEJO__security__INSTALL_LOCK=true \
  -e  FORGEJO__security__SECRET_KEY=supersecretkey \
  -v forgejo-ssh:/data/ssh
