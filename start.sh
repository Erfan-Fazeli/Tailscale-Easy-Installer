#!/bin/bash
set -e

# Configuration
AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-}"
COUNTRY_CODE_OVERRIDE="${COUNTRY_CODE_OVERRIDE:-}"
HTTP_PORT="${HTTP_PORT:-8080}"
DATACENTER_INFO_FILE="/tmp/datacenter_info.txt"
HOSTNAME_COUNT_FILE="/tmp/hostname_counts.txt"

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

# Get datacenter/cloud provider info (cached)
get_datacenter_info() {
    # Check if we have cached info
    if [ -f "$DATACENTER_INFO_FILE" ]; then
        cat "$DATACENTER_INFO_FILE"
        return
    fi

    # Try to get cloud provider info from multiple sources
    local provider=""
    local region=""
    
    # Try AWS metadata
    if aws_info=$(curl -sf --max-time 2 http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null) && [ -n "$aws_info" ]; then
        provider="AWS-${aws_info}"
    # Try GCP metadata
    elif gcp_info=$(curl -sf --max-time 2 -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone 2>/dev/null | awk -F/ '{print $4}'); then
        if [ -n "$gcp_info" ]; then
            provider="GCP-${gcp_info}"
        fi
    # Try Azure metadata
    elif az_info=$(curl -sf --max-time 2 -H "Metadata: true" "http://169.254.169.254/metadata/instance/compute/location?api-version=2021-02-01&format=text" 2>/dev/null); then
        if [ -n "$az_info" ]; then
            provider="Azure-${az_info}"
        fi
    # Try using ipinfo.io for general location info
    else
        local org_info=$(curl -sf --max-time 3 https://ipinfo.io/org 2>/dev/null | cut -d' ' -f1 | sed 's/[^a-zA-Z0-9-]//g')
        local city_info=$(curl -sf --max-time 3 https://ipinfo.io/city 2>/dev/null | tr -d ' ')
        if [ -n "$org_info" ]; then
            provider="${org_info}"
            if [ -n "$city_info" ]; then
                region="${city_info}"
            fi
        fi
    fi

    # Fallback to Unknown if no info found
    [ -z "$provider" ] && provider="Unknown"
    
    local result="$provider"
    [ -n "$region" ] && result="${provider}-${region}"
    
    # Cache the result
    echo "$result" > "$DATACENTER_INFO_FILE"
    echo "$result"
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

# Get next sequential number for hostname uniqueness
get_next_sequence() {
    local prefix="$1"
    local country="$2"
    local datacenter="$3"
    local key="${prefix}__${country}_${datacenter}"
    
    # Initialize count file if it doesn't exist
    [ ! -f "$HOSTNAME_COUNT_FILE" ] && touch "$HOSTNAME_COUNT_FILE"
    
    # Get current count for this combination
    local current_count=$(grep "^${key}:" "$HOSTNAME_COUNT_FILE" 2>/dev/null | tail -1 | cut -d':' -f2)
    [ -z "$current_count" ] && current_count=0
    
    # Increment and save
    local next_count=$((current_count + 1))
    
    # Remove old entry and add new one
    grep -v "^${key}:" "$HOSTNAME_COUNT_FILE" > "${HOSTNAME_COUNT_FILE}.tmp" 2>/dev/null || true
    echo "${key}:${next_count}" >> "${HOSTNAME_COUNT_FILE}.tmp"
    mv "${HOSTNAME_COUNT_FILE}.tmp" "$HOSTNAME_COUNT_FILE"
    
    echo "$next_count"
}

# Generate enhanced hostname
get_hostname() {
    local country="$1"
    local datacenter="$2"
    local sequence="$3"
    local name="${country}-${sequence}"
    
    # Use full hostname format: Prefix-Datacenter-Country-Sequence
    if [ -n "$HOSTNAME_PREFIX" ] && [ -n "$datacenter" ]; then
        name="${HOSTNAME_PREFIX}-${datacenter}-${country}-${sequence}"
    elif [ -n "$HOSTNAME_PREFIX" ]; then
        name="${HOSTNAME_PREFIX}-${country}-${sequence}"
    else
        name="Unknown-${country}-${sequence}"
    fi
    
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
DATACENTER=$(get_datacenter_info)
SEQUENCE=$(get_next_sequence "$HOSTNAME_PREFIX" "$COUNTRY" "$DATACENTER")
HOSTNAME=$(get_hostname "$COUNTRY" "$DATACENTER" "$SEQUENCE")

log "Country: $COUNTRY"
log "Datacenter: $DATACENTER"
log "Hostname: $HOSTNAME"

connect "$HOSTNAME"
log "Connected! IP: $(tailscale ip -4 2>/dev/null || echo 'pending')"

echo "=== Setup complete! ==="
wait
