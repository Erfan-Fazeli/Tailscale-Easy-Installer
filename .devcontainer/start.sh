#!/bin/bash
set -e

# Load .env if exists
echo "Loading .env file..."
if [ -f "/.env" ]; then
    echo "Found .env at: /.env"
    export $(grep -v '^#' /.env | xargs)
elif [ -f "/workspace/Tailscale_AutoNode-Setup/.env" ]; then
    echo "Found .env at: /workspace/Tailscale_AutoNode-Setup/.env"
    export $(grep -v '^#' /workspace/Tailscale_AutoNode-Setup/.env | xargs)
elif [ -f "/app/.env" ]; then
    echo "Found .env at: /app/.env"
    export $(grep -v '^#' /app/.env | xargs)
else
    echo "No .env file found in standard locations"
fi

# Configuration
AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-}"
COUNTRY_CODE_OVERRIDE="${COUNTRY_CODE_OVERRIDE:-}"
HTTP_PORT="${HTTP_PORT:-8080}"

# Simple logging
log() { echo "[$(date +%H:%M:%S)] $1"; }
err() { echo "[ERROR] $1" >&2; exit 1; }

# Detect platform
if [ "$CODESPACES" = "true" ]; then PLATFORM="codespaces"
elif [ -n "$RENDER" ]; then PLATFORM="render"
elif [ -n "$FLY_APP_NAME" ]; then PLATFORM="fly"
elif [ -n "$KOYEB_APP" ]; then PLATFORM="koyeb"
elif [ -n "$RAILWAY_ENVIRONMENT" ]; then PLATFORM="railway"
else PLATFORM="docker"; fi

# Validate auth key
[ -z "$AUTH_KEY" ] && err "TAILSCALE_AUTH_KEY not set. Get one at: https://login.tailscale.com/admin/settings/keys"
[[ ! "$AUTH_KEY" =~ ^tskey-auth- ]] && err "Invalid AUTH_KEY format"

# Start health server
start_health() {
    while true; do
        echo -e "HTTP/1.1 200 OK\r\n\r\n{\"status\":\"ok\"}" | nc -l -p "$HTTP_PORT" -q 1 2>/dev/null || true
    done &
    HEALTH_PID=$!
}

# Start Tailscale daemon
start_daemon() {
    log "Starting Tailscale daemon..."
    sudo tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
    local pid=$!
    log "Tailscale daemon PID: $pid"
    for i in {1..30}; do
        if ps -p $pid > /dev/null; then
            log "Tailscale daemon process is running."
            if ip link show tailscale0 >/dev/null 2>&1; then
                log "Tailscale interface tailscale0 is up."
                return 0
            fi
        fi
        sleep 1
    done
    err "Tailscale daemon failed to start or become responsive"
}

# Enable IP forwarding
enable_forwarding() {
    sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true
    sudo sysctl -w net.ipv6.conf.all.forwarding=1 >/dev/null 2>&1 || true
}

# Detect country code
get_country() {
    [ -n "$COUNTRY_CODE_OVERRIDE" ] && echo "$COUNTRY_CODE_OVERRIDE" && return

    local c=$(curl -sf --max-time 5 https://ipinfo.io/country 2>/dev/null | tr -d '\n' | tr '[:lower:]' '[:upper:]')
    [ -n "$c" ] && [ ${#c} -eq 2 ] && echo "$c" || echo "XX"
}

# Generate hostname
get_hostname() {
    local country="$1"
    local uid="${CODESPACE_NAME:-${RENDER_INSTANCE_ID:-${FLY_ALLOC_ID:-${KOYEB_INSTANCE_ID:-${RAILWAY_REPLICA_ID:-$$-$RANDOM}}}}}"
    local id=$(echo -n "$uid" | md5sum | cut -c1-4)
    local name="${country}-${id}"
    [ -n "$HOSTNAME_PREFIX" ] && name="${HOSTNAME_PREFIX}-${name}"
    echo "$name"
}

# Connect to Tailscale
connect() {
    local hostname="$1"
    for i in {1..3}; do
        sudo tailscale up --authkey="$AUTH_KEY" --hostname="$hostname" --advertise-exit-node --accept-routes --timeout=30s && return 0
        sleep $((2 ** i))
    done
    err "Failed to connect after 3 attempts"
}

# Cleanup on exit
cleanup() {
    sudo tailscale down 2>/dev/null || true
    kill $HEALTH_PID 2>/dev/null || true
}
trap cleanup EXIT SIGTERM SIGINT

# Main
echo "=== Tailscale Auto-Setup ($PLATFORM) ==="

start_health
log "Health server started on port $HTTP_PORT"

start_daemon
log "Tailscale daemon started"

enable_forwarding
log "IP forwarding enabled"

COUNTRY=$(get_country)
HOSTNAME=$(get_hostname "$COUNTRY")
log "Hostname: $HOSTNAME"

connect "$HOSTNAME"
log "Connected! IP: $(sudo tailscale ip -4 2>/dev/null || echo 'pending')"

echo "=== Setup complete! ==="
[ "$PLATFORM" = "codespaces" ] && exit 0
wait
