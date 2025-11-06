#!/bin/bash
# Simple runner that loads .env and runs start.sh with sudo

# Load .env file
if [ -f "$(dirname "$0")/.env" ]; then
    echo "Loading .env file..."
    set -a
    source "$(dirname "$0")/.env"
    set +a
fi

# Export all current environment variables and run start.sh with sudo
sudo -E "$(dirname "$0")/.devcontainer/start.sh"
