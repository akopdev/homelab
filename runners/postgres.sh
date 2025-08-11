#!/bin/bash

run_container docker.io/library/postgres:15-alpine \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data
