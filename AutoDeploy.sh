#!/bin/bash

# Simple Tailscale Auto-Setup - Minimal Version
echo "=== Starting Tailscale Auto-Setup ==="

# Get auth key directly from environment
AUTH_KEY="${TAILSCALE_AUTH_KEY}"
if [ -z "$AUTH_KEY" ]; then
    echo "ERROR: TAILSCALE_AUTH_KEY not set"
    exit 1
fi

# Simple logging
log() { echo "$(date '+%H:%M:%S') $1"; }

# Start health server on port
PORT="${PORT:-10000}"
log "Starting health server on port $PORT"
while true; do
    read request < /dev/tcp/0.0.0.0/$PORT 2>/dev/null || continue
    if echo "$request" | grep -q "GET /health"; then
        echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 15\r\n\r\n{\"status\":\"ok\"}"
    fi
done &
HEALTH_PID=$!

# Start Tailscale daemon
log "Starting Tailscale daemon..."
tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state >/dev/null 2>&1 &

# Wait for daemon
for i in {1..10}; do
    tailscale status >/dev/null 2>&1 && break
    sleep 1
done

# Setup networking
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || true
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || true

# Get simple hostname
COUNTRY=$(curl -sf --max-time 1 ipinfo.io/country 2>/dev/null || echo "XX")
SEQUENCE=$(cat /tmp/count 2>/dev/null || echo "1")
echo $((SEQUENCE + 1)) > /tmp/count

# Generate hostname
HOSTNAME="Tail-Node-${COUNTRY}-${SEQUENCE}"

# Connect to Tailscale - use FULL auth key exactly as provided
log "Connecting with key: ${AUTH_KEY:0:15}..."
tailscale up --authkey="$AUTH_KEY" --hostname="$HOSTNAME" --advertise-exit-node --accept-routes

# Status
IP=$(tailscale ip -4 2>/dev/null || echo "N/A")
echo "══ TAILSCALE CONNECTED ══"
echo "Hostname: $HOSTNAME"
echo "Tailscale IP: $IP"
echo "Status: $(tailscale status 2>/dev/null | head -1 || echo 'Pending approval')"

# Keep alive
log "Services running..."
while true; do
    sleep 60
    tailscale status >/dev/null 2>&1 && echo "[$(date '+%H:%M:%S')] Tailscale active"
done
