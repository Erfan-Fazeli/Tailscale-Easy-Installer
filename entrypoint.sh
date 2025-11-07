#!/bin/bash

echo "=== Starting Tailscale Auto-Setup ==="

# Load .env file if exists
for env_file in .env /workspace/.env /workspaces/.env /app/.env; do
    [ -f "$env_file" ] && source "$env_file" 2>/dev/null && break
done

# Check for auth key
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found"
    exit 1
fi

# Clean and write auth key to secure file
TAILSCALE_AUTH_KEY=$(echo "$TAILSCALE_AUTH_KEY" | sed 's/^"//' | sed 's/"$//')
AUTH_KEY_FILE="/tmp/tailscale-authkey"
echo -n "$TAILSCALE_AUTH_KEY" > "$AUTH_KEY_FILE"
chmod 600 "$AUTH_KEY_FILE"

export TAILSCALE_AUTH_KEY_FILE="$AUTH_KEY_FILE"
exec /AutoDeploy.sh
