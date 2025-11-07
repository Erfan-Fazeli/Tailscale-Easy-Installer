#!/bin/bash
set -e

# Configuration
AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-}"
COUNTRY_CODE_OVERRIDE="${COUNTRY_CODE_OVERRIDE:-}"
HTTP_PORT="${HTTP_PORT:-8080}"

# Simple logging
log() { echo "[$(date +%H:%M:%S)] $1"; }
warn() { echo "[WARN] $1"; }
err() { echo "[ERROR] $1" >&2; exit 1; }

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

    # Try privileged mode first, fallback to userspace if fails
    if tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
    then
        local pid=$!
        sleep 2
        if ps -p $pid > /dev/null 2>&1; then
            log "Tailscale daemon started (kernel mode)"
            return 0
        fi
        warn "Kernel mode failed (pid $pid died)"
        kill $pid 2>/dev/null || true
    fi

    # Fallback to userspace mode
    log "Falling back to userspace networking mode..."
    if tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock & then
        local pid=$!
        sleep 3
        if ps -p $pid > /dev/null 2>&1; then
            log "Tailscale daemon started (userspace mode)"
            return 0
        fi
        err "Tailscale daemon failed to start (pid $pid died). Check permissions."
    else
        err "Failed to start tailscaled. Check if binary exists and permissions are correct."
    fi
}

# Detect country code
get_country() {
    [ -n "$COUNTRY_CODE_OVERRIDE" ] && echo "$COUNTRY_CODE_OVERRIDE" && return

    local c=$(curl -sf --max-time 3 https://ipinfo.io/country 2>/dev/null | tr -d '\n' | tr '[:lower:]' '[:upper:]')
    if [ -n "$c" ] && [ ${#c} -eq 2 ]; then
        echo "$c"
    else
        warn "Could not detect country, using XX"
        echo "XX"
    fi
}

# Generate hostname
get_hostname() {
    local country="$1"
    local id=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 4)
    local name="${country}-${id}"
    [ -n "$HOSTNAME_PREFIX" ] && name="${HOSTNAME_PREFIX}-${name}"
    echo "$name"
}

# Connect to Tailscale
connect() {
    local hostname="$1"

    # Try with exit node first
    log "Attempting to connect as exit node..."
    for i in {1..2}; do
        if tailscale up --authkey="$AUTH_KEY" --hostname="$hostname" --advertise-exit-node --accept-routes --timeout=30s; then
            log "✓ Connected as exit node"
            return 0
        fi
        warn "Exit node attempt $i failed, retrying..."
        sleep 2
    done

    # Fallback: connect without exit node
    log "Exit node mode unavailable, connecting as regular client..."
    if tailscale up --authkey="$AUTH_KEY" --hostname="$hostname" --accept-routes --timeout=30s; then
        log "✓ Connected as regular client"
        return 0
    else
        err "Failed to connect to Tailscale network"
    fi
}

# Cleanup on exit
cleanup() {
    tailscale down 2>/dev/null || true
    kill $HEALTH_PID 2>/dev/null || true
}
trap cleanup EXIT SIGTERM SIGINT

# Main
echo "=== Tailscale Auto-Setup (Docker) ==="

start_health
log "Health server started on port $HTTP_PORT"

start_daemon

# Enable IP forwarding (silently fails in restricted environments)
sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 && log "IP forwarding enabled" || log "IP forwarding not available (restricted environment)"
sysctl -w net.ipv6.conf.all.forwarding=1 >/dev/null 2>&1 || true

COUNTRY=$(get_country)
HOSTNAME=$(get_hostname "$COUNTRY")
log "Hostname: $HOSTNAME"

connect "$HOSTNAME"
log "Connected! IP: $(tailscale ip -4 2>/dev/null || echo 'pending')"

echo "=== Setup complete! ==="
wait
