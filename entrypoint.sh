#!/bin/bash

# Simple entrypoint - just load env and run AutoDeploy

echo "=== Entrypoint: Starting Tailscale Auto-Setup ==="

# Load .env from different locations
for env_file in .env /workspace/.env /workspaces/.env /app/.env; do
    if [ -f "$env_file" ]; then
        echo "Found env file: $env_file"
        source "$env_file" 2>/dev/null && break
    fi
done

# Check for auth key and debug
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found in environment"
    exit 1
fi

# Remove quotes if present
TAILSCALE_AUTH_KEY=$(echo "$TAILSCALE_AUTH_KEY" | sed 's/^"//' | sed 's/"$//')

# Export the cleaned auth key so AutoDeploy.sh can access it
export TAILSCALE_AUTH_KEY

# Debug auth key info (without exposing sensitive data)
echo "✓ Found TAILSCALE_AUTH_KEY"
echo "Auth key length: ${#TAILSCALE_AUTH_KEY}"
echo "Auth key prefix: ${TAILSCALE_AUTH_KEY:0:8}..."

exec /AutoDeploy.sh
