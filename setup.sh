#!/bin/bash

# ============================================================================
# Tailscale Auto-Installer - Quick Setup Script
# ============================================================================
# This script helps you create a .env file securely without exposing secrets
# ============================================================================

set -e

echo "============================================"
echo "  Tailscale Exit Node - Quick Setup"
echo "============================================"
echo

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  Warning: .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

echo "📋 Let's configure your Tailscale exit node..."
echo

# Get AUTH_KEY
echo "🔑 Step 1: Tailscale Auth Key"
echo "   Get your key from: https://login.tailscale.com/admin/settings/keys"
echo "   Make sure it's Reusable and approved for exit nodes"
echo
read -p "Enter your TAILSCALE_AUTH_KEY: " AUTH_KEY

if [ -z "$AUTH_KEY" ]; then
    echo "❌ Error: AUTH_KEY cannot be empty!"
    exit 1
fi

if [[ ! "$AUTH_KEY" =~ ^tskey-auth- ]]; then
    echo "⚠️  Warning: AUTH_KEY should start with 'tskey-auth-'"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Optional settings
echo
echo "⚙️  Step 2: Optional Settings (press Enter to skip)"
echo

read -p "Custom hostname prefix (e.g., myserver): " HOSTNAME_PREFIX
read -p "Override country code (e.g., US, FR): " COUNTRY_CODE_OVERRIDE
read -p "HTTP port (default: 8080): " HTTP_PORT
HTTP_PORT=${HTTP_PORT:-8080}

# Create .env file
echo
echo "📝 Creating .env file..."

cat > .env << EOF
# ================================
# TAILSCALE AUTO-INSTALLER CONFIG
# ================================
# Generated on: $(date)

# REQUIRED: Tailscale Authentication Key
TAILSCALE_AUTH_KEY=${AUTH_KEY}

# OPTIONAL: Custom hostname prefix
${HOSTNAME_PREFIX:+HOSTNAME_PREFIX=${HOSTNAME_PREFIX}}

# OPTIONAL: Override country code detection
${COUNTRY_CODE_OVERRIDE:+COUNTRY_CODE_OVERRIDE=${COUNTRY_CODE_OVERRIDE}}

# OPTIONAL: HTTP Health Server Port
HTTP_PORT=${HTTP_PORT}

# OPTIONAL: Enable detailed logging
ENABLE_LOGGING=true

# OPTIONAL: Connection retry settings
MAX_RETRIES=5

# OPTIONAL: Country detection timeout (seconds)
COUNTRY_LOOKUP_TIMEOUT=5
EOF

echo "✅ .env file created successfully!"
echo

# Verify .gitignore exists
if [ ! -f ".gitignore" ]; then
    echo "⚠️  Warning: .gitignore not found!"
    echo "   Creating .gitignore to protect your secrets..."
    cat > .gitignore << 'GITIGNORE'
# Environment variables with secrets
.env
.env.local
.env.*.local

# Tailscale state
tailscale-state/

# IDE files
.vscode/
.idea/
*.swp

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
GITIGNORE
    echo "✅ .gitignore created"
fi

# Final instructions
echo
echo "============================================"
echo "  Setup Complete! 🎉"
echo "============================================"
echo
echo "Next steps:"
echo
echo "1️⃣  Start the container:"
echo "   docker-compose up -d"
echo
echo "2️⃣  Check logs:"
echo "   docker-compose logs -f"
echo
echo "3️⃣  Verify Tailscale connection:"
echo "   docker exec -it tailscale-exit-node sudo tailscale status"
echo
echo "4️⃣  Approve exit node (if needed):"
echo "   Visit: https://login.tailscale.com/admin/machines"
echo
echo "⚠️  IMPORTANT: Never commit .env to git!"
echo "   Your .env is protected by .gitignore ✅"
echo
echo "============================================"
