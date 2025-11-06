#!/bin/bash
set -e

# Load .env if exists
[ -f /.env ] && source /.env
[ -f .env ] && source .env

# Check for auth key
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not found in .env file"
    echo "Get key: https://login.tailscale.com/admin/settings/keys"
    sleep infinity
fi

exec /start.sh
