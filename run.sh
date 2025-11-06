#!/bin/bash
# Simple runner that loads .env and runs the container

# Load .env file
if [ -f "$(dirname "$0")/.env" ]; then
    echo "Loading .env file..."
    set -a
    source "$(dirname "$0")/.env"
    set +a
fi

# Build the docker image
docker build -t tailscale-autonode .

# Run the docker container
docker run -d --name tailscale-autonode --env-file .env -p 8080:8080 tailscale-autonode
