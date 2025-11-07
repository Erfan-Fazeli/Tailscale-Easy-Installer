#!/bin/bash
set -e

# Find and load .env
for env_file in /workspaces/*/\.env /workspace/.env /.env .env; do
    if [ -f "$env_file" ]; then
        echo "Loading .env from: $env_file"
        source "$env_file"
        break
    fi
done

# Export environment variables
export TAILSCALE_AUTH_KEY HOSTNAME_PREFIX COUNTRY_CODE_OVERRIDE HTTP_PORT

# Check for auth key
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found"
    echo "Get key: https://login.tailscale.com/admin/settings/keys"
    sleep infinity
fi

echo "✓ Found TAILSCALE_AUTH_KEY"
/start.sh
