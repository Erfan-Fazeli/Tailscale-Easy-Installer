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

# Enhanced debugging - show what's actually loaded from env files
echo "=== Entrypoint: Environment debugging ==="
echo "TAILSCALE_AUTH_KEY from environment: [length=${#TAILSCALE_AUTH_KEY}, first 20='${TAILSCALE_AUTH_KEY:0:20}', last 10='${TAILSCALE_AUTH_KEY: -10}']"

# Remove quotes if present
TAILSCALE_AUTH_KEY=$(echo "$TAILSCALE_AUTH_KEY" | sed 's/^"//' | sed 's/"$//')

# Debug auth key info (without exposing sensitive data)
echo "✓ Found and cleaned TAILSCALE_AUTH_KEY"
echo "Auth key length: ${#TAILSCALE_AUTH_KEY}"
echo "Auth key preview: ${TAILSCALE_AUTH_KEY:0:8}...${TAILSCALE_AUTH_KEY: -8}"

# NEW APPROACH: Write auth key to a secure file
# This avoids any environment variable truncation or escaping issues
AUTH_KEY_FILE="/tmp/tailscale-authkey"
echo -n "$TAILSCALE_AUTH_KEY" > "$AUTH_KEY_FILE"
chmod 600 "$AUTH_KEY_FILE"

# Verify the file was created correctly
if [ -f "$AUTH_KEY_FILE" ]; then
    FILE_KEY_LENGTH=$(wc -c < "$AUTH_KEY_FILE" | tr -d ' ')
    echo "✓ Auth key written to file: $AUTH_KEY_FILE"
    echo "File size: $FILE_KEY_LENGTH bytes"
    echo "First 20 chars from file: $(head -c 20 "$AUTH_KEY_FILE")"
    echo "Last 10 chars from file: $(tail -c 10 "$AUTH_KEY_FILE")"
else
    echo "ERROR: Failed to create auth key file"
    exit 1
fi

# Export the file path for AutoDeploy.sh
export TAILSCALE_AUTH_KEY_FILE="$AUTH_KEY_FILE"
export TAILSCALE_AUTH_KEY

exec /AutoDeploy.sh
