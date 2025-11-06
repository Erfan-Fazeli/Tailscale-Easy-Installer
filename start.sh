#!/bin/bash
# Tailscale Exit Node - Universal Startup Script
# Works on: Codespaces, Render, Fly.io, Railway, Koyeb, Docker
set -e

# Logging
log() { echo "[$(date '+%H:%M:%S')] $*"; }
err() { echo "[$(date '+%H:%M:%S')] ❌ $*" >&2; exit 1; }

log "🚀 Starting Tailscale Exit Node..."

# Detect platform
if [ -n "${CODESPACES:-}" ]; then PLATFORM="Codespaces"
elif [ -n "${RENDER:-}" ]; then PLATFORM="Render"
elif [ -n "${FLY_APP_NAME:-}" ]; then PLATFORM="Fly.io"
elif [ -n "${RAILWAY_ENVIRONMENT:-}" ]; then PLATFORM="Railway"
elif [ -n "${KOYEB_DEPLOYMENT_ID:-}" ]; then PLATFORM="Koyeb"
else PLATFORM="Docker"; fi

log "Platform: $PLATFORM"

# Validate auth key
[ -z "${TAILSCALE_AUTH_KEY:-}" ] && err "TAILSCALE_AUTH_KEY not set! See README.md"
[[ ! "$TAILSCALE_AUTH_KEY" =~ ^tskey-auth- ]] && log "⚠️  Warning: AUTH_KEY format unusual"

# Detect country for hostname
COUNTRY="${COUNTRY_CODE_OVERRIDE:-$(timeout 5 curl -s https://ipapi.co/country/ 2>/dev/null || echo XX)}"
UNIQUE_ID="${CODESPACE_NAME:-${RENDER_SERVICE_ID:-${FLY_ALLOC_ID:-$(hostname)}}}"
HOSTNAME="${HOSTNAME_PREFIX:-$COUNTRY}-$(echo -n "$UNIQUE_ID" | md5sum | cut -c1-4)"

log "Hostname: $HOSTNAME"
log "Country: $COUNTRY"

# Ensure TUN device exists
[ ! -e /dev/net/tun ] && { mkdir -p /dev/net; mknod /dev/net/tun c 10 200 2>/dev/null || true; }
[ -e /dev/net/tun ] && log "✅ /dev/net/tun ready" || log "⚠️  /dev/net/tun missing"

# Start Tailscale daemon
log "Starting tailscaled..."
tailscaled --state=mem: --socket=/var/run/tailscale/tailscaled.sock &
TAILSCALED_PID=$!

# Wait for daemon
for i in {1..30}; do
    [ -S /var/run/tailscale/tailscaled.sock ] && break
    [ $i -eq 30 ] && err "Tailscaled failed to start"
    sleep 1
done
log "✅ Tailscaled ready (PID: $TAILSCALED_PID)"

# Connect to Tailscale
log "Connecting to Tailscale network..."
tailscale up \
    --authkey="$TAILSCALE_AUTH_KEY" \
    --hostname="$HOSTNAME" \
    --advertise-exit-node \
    --ssh \
    --accept-routes \
    --reset || err "Failed to connect"

log "✅ Connected to Tailscale!"
log ""
tailscale status
log ""
log "Tailscale IPs:"
tailscale ip -4 2>/dev/null || true
tailscale ip -6 2>/dev/null || true
log ""

# Health check server
HTTP_PORT="${HTTP_PORT:-8080}"
log "Starting health server on :$HTTP_PORT"
(while true; do
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"status\":\"ok\",\"hostname\":\"$HOSTNAME\",\"platform\":\"$PLATFORM\"}" | nc -l -p "$HTTP_PORT" -q 1 2>/dev/null
done) &

log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "✅ Tailscale Exit Node is RUNNING!"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log ""
log "📋 Status:"
log "   Platform: $PLATFORM"
log "   Hostname: $HOSTNAME"
log "   Country: $COUNTRY"
log "   Health: http://localhost:$HTTP_PORT/health"
log ""
log "🔗 Next Steps:"
log "   1. Approve exit node at: https://login.tailscale.com/admin/machines"
log "   2. Find your node by hostname: $HOSTNAME"
log "   3. Click 'Allow as exit node'"
log ""
log "📊 View Logs:"
if [ "$PLATFORM" = "Codespaces" ]; then
    log "   tail -f /tmp/tailscale.log"
elif [ "$PLATFORM" = "Docker" ]; then
    log "   docker-compose logs -f"
else
    log "   Check your platform's log viewer"
fi
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "✅ Setup complete! Service running in background..."
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log ""

# Keep alive
wait $TAILSCALED_PID
