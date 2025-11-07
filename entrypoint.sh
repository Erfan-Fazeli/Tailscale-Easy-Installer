#!/bin/bash
set -e

# Find and load .env file
for env_file in /workspaces/*/\.env /workspace/.env /.env .env; do
    if [ -f "$env_file" ]; then
        echo "Loading .env from: $env_file"
        set -a
        source "$env_file"
        set +a
        break
    fi
done

# Validate auth key
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found in .env"
    echo "Get your auth key: https://login.tailscale.com/admin/settings/keys"
    sleep infinity
fi

# Run setup
exec /start.sh
