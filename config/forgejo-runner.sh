#!/bin/sh

set -e

if [ -z "$FORGEJO_RUNNER_SECRET" ] || [ -z "$FORGEJO_INSTANCE_URL" ]; then
  echo "[FAILED] Error initializing the runner. Not all required variables are defined."
  exit 1
fi

if [ -f "/data/.runner" ]; then
  echo "[ INFO ] Runner configuration already exists."
  echo "[  OK  ] Starting the daemon..."
  forgejo-runner daemon --config /data/.runner
else
  echo "[ INFO ] Registering runner with Forgejo..."

  forgejo-runner create-runner-file --instance "$FORGEJO_INSTANCE_URL" --name "Default" --secret "$FORGEJO_RUNNER_SECRET" 
  # Add labels to runner file
  sed -i -e "s|\"labels\": null|\"labels\": [\"python-3.13:docker://python:3.13\"]|" /data/.runner ;

  echo "[  OK  ] Starting the daemon..."
  forgejo-runner daemon
fi
