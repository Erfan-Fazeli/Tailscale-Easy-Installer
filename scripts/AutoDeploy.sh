#!/bin/bash

echo "=== Starting Tailscale Auto-Setup ==="

log() { echo "$(date '+%H:%M:%S') $1"; }

# Get auth key from file or environment
if [ -n "$TAILSCALE_AUTH_KEY_FILE" ] && [ -f "$TAILSCALE_AUTH_KEY_FILE" ]; then
    AUTH_KEY=$(cat "$TAILSCALE_AUTH_KEY_FILE" | tr -d '\n\r')
elif [ -n "$TAILSCALE_AUTH_KEY" ]; then
    AUTH_KEY="$TAILSCALE_AUTH_KEY"
else
    log "ERROR: TAILSCALE_AUTH_KEY not found"
    exit 1
fi

# Start health server using external Python script
PORT="${PORT:-10000}"
log "Starting health server on port $PORT"

# Use the external health server script only
if [ -f "/healthApi.py" ] && command -v python3 >/dev/null 2>&1; then
    export PORT=$PORT
    python3 /healthApi.py &
    HEALTH_PID=$!
    log "Health server started with external script (PID: $HEALTH_PID)"
else
    log "Warning: healthApi.py not found or Python3 not available, health server not started"
    HEALTH_PID=""
fi

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

# Use ipInfo.py script to get IP geolocation data
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-erf}" # Default to 'erf' if not set

# Run ipInfo.py to get IP information
if [ -f "/ipInfo.py" ] && command -v python3 >/dev/null 2>&1; then
    log "Getting IP geolocation information..."
    IP_DATA=$(python3 /ipInfo.py 2>/dev/null || echo "XX-UnknownRegion-UnknownProvider")
    
    # Parse the output to extract components
    COUNTRY=$(echo "$IP_DATA" | cut -d'-' -f1)
    REGION=$(echo "$IP_DATA" | cut -d'-' -f2)
    ORG=$(echo "$IP_DATA" | cut -d'-' -f3)
else
    log "Warning: ipInfo.py not found, using fallback data"
    COUNTRY="XX"
    REGION="UnknownRegion"
    ORG="UnknownProvider"
fi

# Sanitize strings for hostname
# Replace non-alphanumeric characters with a single hyphen, convert to lowercase, and remove leading/trailing hyphens
REGION_SANITIZED=$(echo "$REGION" | sed -E 's/[^a-zA-Z0-9]+/-/g' | tr '[:upper:]' '[:lower:]' | sed -E 's/^-+|-+$//g')
ORG_SANITIZED=$(echo "$ORG" | sed -E 's/[^a-zA-Z0-9]+/-/g' | tr '[:upper:]' '[:lower:]' | sed -E 's/^-+|-+$//g')

# Use default if sanitized values are empty or contain only hyphens
REGION_SANITIZED="${REGION_SANITIZED:-unknown-region}"
ORG_SANITIZED="${ORG_SANITIZED:-unknown-provider}"

# Ensure values are not empty after sanitization
if [ -z "$REGION_SANITIZED" ] || [ "$REGION_SANITIZED" = "-" ]; then
    REGION_SANITIZED="unknown-region"
fi

if [ -z "$ORG_SANITIZED" ] || [ "$ORG_SANITIZED" = "-" ]; then
    ORG_SANITIZED="unknown-provider"
fi

# Fixed sequence number - read current count and increment properly
if [ -f "/tmp/count" ]; then
    SEQUENCE=$(($(cat /tmp/count) + 1))
else
    SEQUENCE=1
fi
echo "$SEQUENCE" > /tmp/count

# Generate hostname without duplicate separators
HOSTNAME=$(echo "${HOSTNAME_PREFIX}${ORG_SANITIZED}-${REGION_SANITIZED}-${COUNTRY}-${SEQUENCE}" | sed 's/[-]+/-/g' | sed 's/^-*//' | sed 's/-*$//')

log "Generated hostname components:"
log "  Prefix: $HOSTNAME_PREFIX"
log "  Org: $ORG_SANITIZED (original: $ORG)"
log "  Region: $REGION_SANITIZED (original: $REGION)"
log "  Country: $COUNTRY"
log "  Sequence: $SEQUENCE"

# Connect to Tailscale
log "Connecting to Tailscale..."
tailscale up \
    --authkey="${AUTH_KEY}" \
    --hostname="$HOSTNAME" \
    --advertise-exit-node \
    --accept-routes \
    --timeout=10s \
    --operator="$USER"

if [ $? -eq 0 ]; then
    log "✓ Connected to Tailscale successfully"
else
    log "ERROR: Failed to connect to Tailscale"
    log "Please check your auth key at: https://login.tailscale.com/admin/settings/keys"
fi

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
