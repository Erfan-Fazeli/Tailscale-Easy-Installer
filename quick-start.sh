#!/bin/bash

# ============================================================================
# Quick Start Script - Fully Automated, No User Input Required
# ============================================================================

set -e

echo "============================================"
echo "  Tailscale Exit Node - Quick Start"
echo "============================================"
echo

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo
    echo "Creating .env from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "⚠️  Warning: .env created but TAILSCALE_AUTH_KEY needs to be set!"
        echo "   Please edit .env and add your auth key, then run this script again."
        exit 1
    else
        echo "❌ Error: .env.example not found!"
        exit 1
    fi
fi

# Check if AUTH_KEY is set (basic validation)
if ! grep -q "TAILSCALE_AUTH_KEY=tskey-auth-" .env 2>/dev/null; then
    echo "⚠️  Warning: TAILSCALE_AUTH_KEY may not be set correctly in .env"
    echo "   Continuing anyway..."
fi

# Detect docker-compose command
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ Error: docker-compose not found!"
    echo "   Please install Docker and Docker Compose first."
    exit 1
fi

echo "🚀 Starting Tailscale exit node..."
echo "   Using command: $COMPOSE_CMD"
echo

# Start the container
$COMPOSE_CMD up -d

echo
echo "⏳ Waiting for container to initialize..."
sleep 5

echo
echo "�� Container status:"
$COMPOSE_CMD ps

echo
echo "📋 Recent logs:"
$COMPOSE_CMD logs --tail=30

echo
echo "============================================"
echo "  🎉 Container started successfully!"
echo "============================================"
echo
echo "✅ Tailscale exit node is now running!"
echo
echo "📌 Quick commands:"
echo
echo "  📋 View live logs:"
echo "     $COMPOSE_CMD logs -f"
echo
echo "  🔍 Check Tailscale status:"
echo "     docker exec -it tailscale-exit-node sudo tailscale status"
echo
echo "  🌐 Check health endpoint:"
echo "     curl http://localhost:8080/health"
echo
echo "  🛑 Stop container:"
echo "     $COMPOSE_CMD down"
echo
echo "  🔄 Restart container:"
echo "     $COMPOSE_CMD restart"
echo
echo "============================================"
echo
echo "📝 Next steps:"
echo "  1. Check logs to verify connection"
echo "  2. Find your hostname in logs (e.g., US-1, FR-1)"
echo "  3. Approve exit node at: https://login.tailscale.com/admin/machines"
echo "  4. Start using the exit node from any device!"
echo
echo "✅ Setup complete! Container will auto-restart on reboot."
echo
