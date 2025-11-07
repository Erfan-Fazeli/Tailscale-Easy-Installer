#!/bin/bash
set -e

# Config
AUTH_KEY="${TAILSCALE_AUTH_KEY:-${TS_AUTHKEY:-}}"
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-Node}"
COUNTRY_CODE_OVERRIDE="${COUNTRY_CODE_OVERRIDE:-}"
HTTP_PORT="${HTTP_PORT:-8080}"

# Logging
log() { echo "[$(date +%H:%M:%S)] $1"; }
err() { echo "[ERROR] $1" >&2; exit 1; }

# Check auth key
[ -z "$AUTH_KEY" ] && err "TAILSCALE_AUTH_KEY not set - Get one: https://login.tailscale.com/admin/settings/keys"
[[ ! "$AUTH_KEY" =~ ^tskey-auth- ]] && err "Invalid auth key format"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Starting Tailscale Auto-Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Health server
log "Starting health server on port $HTTP_PORT..."
while true; do
    echo -e "HTTP/1.1 200 OK\r\n\r\nOK" | nc -l -p "$HTTP_PORT" -q 1 || true
done &

# Start Tailscale daemon
log "Starting Tailscale daemon..."
rm -f /var/run/tailscale/*.sock 2>/dev/null || true

tailscaled --tun=userspace-networking \
    --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock &

# Wait for daemon
log "Waiting for daemon..."
for i in {1..15}; do
    sleep 1
    tailscale status >/dev/null 2>&1 && break
done

if ! tailscale status >/dev/null 2>&1; then
    err "Daemon failed to start"
fi
log "✓ Daemon ready"

# Setup IP forwarding
log "Configuring network..."
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null || true
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || true
iptables -t nat -A POSTROUTING -s 100.64.0.0/10 -j MASQUERADE 2>/dev/null || true

# Get country
COUNTRY="$COUNTRY_CODE_OVERRIDE"
if [ -z "$COUNTRY" ]; then
    COUNTRY=$(curl -sf --max-time 3 https://ipinfo.io/country 2>/dev/null | tr -d '\n' | tr '[:lower:]' '[:upper:]')
    [ -z "$COUNTRY" ] && COUNTRY="XX"
fi

# Generate hostname
RANDOM_ID=$(date +%s%N | md5sum | head -c 6)
HOSTNAME="${HOSTNAME_PREFIX}-${COUNTRY}-${RANDOM_ID}"

log "Hostname: $HOSTNAME"
log "Country: $COUNTRY"
log "Connecting to Tailscale..."

# Connect as exit node
if tailscale up --authkey="$AUTH_KEY" \
    --hostname="$HOSTNAME" \
    --advertise-exit-node \
    --accept-routes \
    --timeout=30s; then
    log "✓ Connected as exit node"
else
    log "Trying without exit node..."
    tailscale up --authkey="$AUTH_KEY" \
        --hostname="$HOSTNAME" \
        --accept-routes \
        --timeout=30s || err "Connection failed"
    log "✓ Connected (exit node needs manual approval)"
fi

# Get connection info
TS_IP=$(tailscale ip -4 2>/dev/null || echo "N/A")
PUBLIC_IP=$(curl -sf --max-time 3 ifconfig.me 2>/dev/null || echo "N/A")

# Show summary
cat <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ TAILSCALE CONNECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Hostname:    $HOSTNAME
  Tailscale:   $TS_IP
  Public IP:   $PUBLIC_IP
  Country:     $COUNTRY

  Admin:       https://login.tailscale.com/admin/machines
  Health:      http://localhost:$HTTP_PORT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

log "Setup complete"
sleep infinity
