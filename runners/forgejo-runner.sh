#!/bin/bash

run_container codeberg.org/forgejo/act_runner:latest \
  -e GITEA_INSTANCE_URL=http://forgejo:3000/ \
  -e GITEA_RUNNER_REGISTRATION_TOKEN=your_registration_token \
  -v runner-data:/data
