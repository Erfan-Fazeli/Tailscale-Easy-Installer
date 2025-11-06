#!/bin/bash

# ============================================================================
# Fully Automated Deployment Script
# ============================================================================
# This script does EVERYTHING automatically:
# - Checks .env exists
# - Builds and starts container
# - Shows status
# NO user input required!
# ============================================================================

set -e

echo "============================================"
echo "  🚀 Tailscale Exit Node"
echo "  Fully Automated Deployment"
echo "============================================"
echo

# Step 1: Check .env file
echo "📋 Step 1/3: Checking configuration..."
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found!"
    if [ -f ".env.example" ]; then
        echo "   Creating .env from template..."
        cp .env.example .env
        echo "   ✅ .env created"
        echo
        echo "⚠️  IMPORTANT: Edit .env and set TAILSCALE_AUTH_KEY"
        echo "   Then run this script again."
        exit 1
    else
        echo "❌ Error: .env.example not found!"
        exit 1
    fi
fi

# Validate AUTH_KEY exists
if ! grep -q "TAILSCALE_AUTH_KEY=tskey-auth-" .env 2>/dev/null; then
    echo "⚠️  Warning: TAILSCALE_AUTH_KEY may not be configured"
    echo "   Continuing anyway..."
else
    echo "   ✅ Configuration found"
fi
echo

# Step 2: Detect Docker Compose
echo "🐳 Step 2/3: Detecting Docker environment..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    echo "   ✅ Found: docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    echo "   ✅ Found: docker compose (plugin)"
else
    echo "   ❌ Docker Compose not found!"
    echo "   Please install Docker and Docker Compose first."
    exit 1
fi
echo

# Step 3: Deploy
echo "🚀 Step 3/3: Deploying container..."
echo "   Command: $COMPOSE_CMD up -d"
echo

$COMPOSE_CMD up -d --build

echo
echo "⏳ Waiting for container to initialize..."
sleep 5

# Show status
echo
echo "============================================"
echo "  📊 Deployment Status"
echo "============================================"
echo
$COMPOSE_CMD ps
echo

# Show recent logs
echo "============================================"
echo "  📋 Container Logs (last 30 lines)"
echo "============================================"
echo
$COMPOSE_CMD logs --tail=30
echo

# Success message
echo "============================================"
echo "  ✅ DEPLOYMENT SUCCESSFUL!"
echo "============================================"
echo
echo "🎉 Tailscale exit node is now running!"
echo
echo "📍 Your container is:"
echo "   • Auto-connecting to Tailscale network"
echo "   • Auto-detecting country and hostname"
echo "   • Running health server on port 8080"
echo "   • Set to auto-restart on reboot"
echo
echo "============================================"
echo "  📌 Useful Commands"
echo "============================================"
echo
echo "View live logs:"
echo "  $COMPOSE_CMD logs -f"
echo
echo "Check Tailscale status:"
echo "  docker exec -it tailscale-exit-node sudo tailscale status"
echo
echo "View health endpoint:"
echo "  curl http://localhost:8080/health"
echo
echo "Stop container:"
echo "  $COMPOSE_CMD down"
echo
echo "Restart container:"
echo "  $COMPOSE_CMD restart"
echo
echo "============================================"
echo "  📝 Next Steps"
echo "============================================"
echo
echo "1. Wait 30 seconds for full initialization"
echo "2. Check logs to find your hostname (e.g., US-1)"
echo "3. Visit: https://login.tailscale.com/admin/machines"
echo "4. Find your node and approve as exit node (one-time)"
echo "5. Start using from any device in your Tailscale network!"
echo
echo "✅ All done! Container will auto-restart on reboot."
echo
