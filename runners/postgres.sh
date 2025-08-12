#!/bin/bash

run_container docker.io/library/postgres:15-alpine \
  -p 5432:5432 \
  -e  POSTGRES_DB=forgejo \
  -e  POSTGRES_USER=forgejo \
  -e  POSTGRES_PASSWORD=changeme \
  -v postgres-data:/var/lib/postgresql/data
