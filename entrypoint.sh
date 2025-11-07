#!/bin/bash
set -e

# Find and load .env from multiple locations
for env_file in /workspaces/*/\.env /workspace/.env /.env .env; do
    if [ -f "$env_file" ]; then
        echo "Loading .env from: $env_file"
        source "$env_file"
        break
    fi
done

# Check for auth key
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found"
    echo "Checked locations: /workspaces/*/.env, /workspace/.env, /.env, .env"
    echo "Get key: https://login.tailscale.com/admin/settings/keys"
    sleep infinity
fi

echo "✓ Found TAILSCALE_AUTH_KEY"
exec /start.sh
