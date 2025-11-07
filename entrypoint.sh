#!/bin/bash

# Simple entrypoint - just load env and run AutoDeploy

# Load .env from different locations
for env_file in .env /workspace/.env /workspaces/.env /app/.env; do
    if [ -f "$env_file" ]; then
        source "$env_file" 2>/dev/null && break
    fi
done

# Check for auth key
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found"
    exit 1
fi

echo "✓ Found TAILSCALE_AUTH_KEY"
exec /AutoDeploy.sh
