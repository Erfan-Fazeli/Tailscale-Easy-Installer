#!/bin/bash

# Tailscale Auth Key Verification Script
# This script helps diagnose auth key issues

echo "========================================="
echo "Tailscale Auth Key Diagnostic Tool"
echo "========================================="
echo ""

# Get the auth key from .env or environment
if [ -f ".env" ]; then
    source .env
    echo "✓ Loaded .env file"
fi

if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "❌ ERROR: TAILSCALE_AUTH_KEY not found"
    echo ""
    echo "Please set it by either:"
    echo "1. Creating a .env file with: TAILSCALE_AUTH_KEY=your-key-here"
    echo "2. Running: export TAILSCALE_AUTH_KEY=your-key-here"
    exit 1
fi

# Clean the key
AUTH_KEY=$(echo "$TAILSCALE_AUTH_KEY" | sed 's/^"//' | sed 's/"$//' | tr -d '\n\r')

echo ""
echo "Auth Key Analysis:"
echo "===================="
echo "Length: ${#AUTH_KEY} characters"
echo "First 20 chars: ${AUTH_KEY:0:20}"
echo "Last 15 chars: ${AUTH_KEY: -15}"
echo ""

# Check key format
if [[ ! "$AUTH_KEY" =~ ^tskey-auth- ]]; then
    echo "❌ INVALID FORMAT: Auth key should start with 'tskey-auth-'"
    echo "   Your key starts with: ${AUTH_KEY:0:20}"
    exit 1
else
    echo "✓ Format looks correct (starts with 'tskey-auth-')"
fi

# Check length
if [ ${#AUTH_KEY} -lt 40 ]; then
    echo "❌ INVALID LENGTH: Auth key is too short (${#AUTH_KEY} chars)"
    exit 1
elif [ ${#AUTH_KEY} -gt 100 ]; then
    echo "❌ INVALID LENGTH: Auth key is too long (${#AUTH_KEY} chars)"
    exit 1
else
    echo "✓ Length is reasonable (${#AUTH_KEY} chars)"
fi

# Check for invalid characters
if echo "$AUTH_KEY" | grep -q '[^a-zA-Z0-9_-]'; then
    echo "❌ WARNING: Auth key contains unexpected characters"
    echo "   Valid characters: a-z, A-Z, 0-9, -, _"
    echo ""
    echo "Hex dump of key:"
    echo "$AUTH_KEY" | od -c
else
    echo "✓ No unexpected characters found"
fi

echo ""
echo "Key Structure Breakdown:"
echo "========================"
# Parse the key structure
PREFIX=$(echo "$AUTH_KEY" | cut -d'-' -f1-2)
BODY=$(echo "$AUTH_KEY" | cut -d'-' -f3-)

echo "Prefix: $PREFIX"
echo "Body: $BODY"
echo "Body segments: $(echo "$BODY" | tr '-' '\n' | wc -l)"

echo ""
echo "========================================="
echo "Recommended Actions:"
echo "========================================="
echo ""
echo "If all checks passed but Tailscale still rejects the key:"
echo ""
echo "1. Go to: https://login.tailscale.com/admin/settings/keys"
echo "2. Check if this key is listed and not expired/revoked"
echo "3. If it's missing or expired, generate a NEW key with:"
echo "   ✓ Reusable: ON"
echo "   ✓ Expiration: 90 days or more"
echo "   ✓ Ephemeral: Optional (ON for auto-cleanup)"
echo "   ✓ Pre-approved: Optional (ON to skip manual approval)"
echo ""
echo "4. Copy the NEW key and update your .env or Render environment"
echo ""
echo "========================================="
