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

# Export environment variables so they're available to child processes
export TAILSCALE_AUTH_KEY
export HOSTNAME_PREFIX
export COUNTRY_CODE_OVERRIDE
export HTTP_PORT

# Check for auth key
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found"
    echo "Checked locations: /workspaces/*/.env, /workspace/.env, /.env, .env"
    echo "Get key: https://login.tailscale.com/admin/settings/keys"
    sleep infinity
fi

echo "✓ Found TAILSCALE_AUTH_KEY"
# Run AutoDeploy.sh in the foreground with full output
exec /AutoDeploy.sh
