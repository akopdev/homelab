#!/usr/bin/env bash

run_container  docker.io/library/nginx:latest \
-p 80:80 \
-p 443:443 \
-v /etc/homelab/configs/nginx.conf:/etc/nginx/conf.d/default.conf:ro
