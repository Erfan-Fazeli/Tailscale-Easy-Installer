#!/bin/bash

# Simple entrypoint - just load env and run AutoDeploy

echo "=== Entrypoint: Starting Tailscale Auto-Setup ==="

# Find the .env file
ENV_FILE=""
for f in .env /workspace/.env /workspaces/.env /app/.env; do
    if [ -f "$f" ]; then
        ENV_FILE="$f"
        echo "Found env file: $ENV_FILE"
        break
    fi
done

if [ -z "$ENV_FILE" ]; then
    echo "ERROR: .env file not found in expected locations."
    exit 1
fi

# Extract TAILSCALE_AUTH_KEY directly from the .env file
AUTH_KEY=$(grep '^TAILSCALE_AUTH_KEY=' "$ENV_FILE" | cut -d '=' -f2-)

if [ -z "$AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found or is empty in $ENV_FILE"
    exit 1
fi

# Debug auth key info (without exposing sensitive data)
echo "✓ Found TAILSCALE_AUTH_KEY in $ENV_FILE"
echo "Auth key length: ${#AUTH_KEY}"
echo "Auth key prefix: ${AUTH_KEY:0:8}..."

exec /AutoDeploy.sh "$AUTH_KEY"
