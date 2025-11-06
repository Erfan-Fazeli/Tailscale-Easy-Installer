#!/bin/bash

# ============================================================================
# Codespaces Runner - Shows all logs in terminal
# ============================================================================
# Run this script in Codespaces to see Tailscale logs in real-time
# Usage: ./run-tailscale.sh
# ============================================================================

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║         🚀 Starting Tailscale Exit Node...                   ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if TAILSCALE_AUTH_KEY is set
if [ -z "${TAILSCALE_AUTH_KEY:-}" ]; then
    echo "❌ ERROR: TAILSCALE_AUTH_KEY is not set!"
    echo ""
    echo "Please set it as a Codespace Secret:"
    echo "1. Go to: https://github.com/settings/codespaces"
    echo "2. Click 'New secret'"
    echo "3. Name: TAILSCALE_AUTH_KEY"
    echo "4. Value: tskey-auth-xxxxxx (get from https://login.tailscale.com/admin/settings/keys)"
    echo "5. Rebuild Codespace"
    echo ""
    exit 1
fi

echo "✅ TAILSCALE_AUTH_KEY is configured"
echo ""
echo "Starting Tailscale with full logging..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run start.sh with sudo to see all logs
exec sudo /usr/local/bin/start.sh
