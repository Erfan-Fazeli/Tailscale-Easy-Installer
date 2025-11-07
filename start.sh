#!/bin/bash
set -e

# Configuration
AUTH_KEY="${TAILSCALE_AUTH_KEY:-${TS_AUTHKEY:-}}"
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-}"
COUNTRY_CODE_OVERRIDE="${COUNTRY_CODE_OVERRIDE:-}"
HTTP_PORT="${HTTP_PORT:-8080}"
DATACENTER_INFO_FILE="/tmp/datacenter_info.txt"
HOSTNAME_COUNT_FILE="/tmp/hostname_counts.txt"

# Simple logging
log() { echo "[$(date +%H:%M:%S)] $1"; }
warn() { echo "[WARN] $1"; }
err() { echo "[ERROR] $1" >&2; exit 1; }

# Try to get auth key from multiple sources (for one-click deploy)
if [ -z "$AUTH_KEY" ]; then
    [ -f /run/secrets/tailscale_key ] && AUTH_KEY=$(cat /run/secrets/tailscale_key) && log "Using mounted secret"
    [ -z "$AUTH_KEY" ] && [ -f /secrets/TAILSCALE_AUTH_KEY ] && AUTH_KEY=$(cat /secrets/TAILSCALE_AUTH_KEY)
fi

# Validate auth key
[ -z "$AUTH_KEY" ] && err "TAILSCALE_AUTH_KEY not set. Get one at: https://login.tailscale.com/admin/settings/keys"
[[ ! "$AUTH_KEY" =~ ^tskey-auth- ]] && err "Invalid AUTH_KEY format"

# Start health server
start_health() {
    # Create a more robust health server that doesn't interfere with terminal output
    {
        while true; do
            echo -e "HTTP/1.1 200 OK\r\n\r\n{\"status\":\"ok\"}" | nc -l -p "$HTTP_PORT" -q 1 2>/dev/null || true
        done
    } &
    HEALTH_PID=$!
}

# Start Tailscale daemon
start_daemon() {
    log "Starting Tailscale daemon..."

    # Clean up any existing sockets first
    rm -f /var/run/tailscale/tailscaled.sock
    rm -f /run/tailscale/tailscaled.sock
    
    # Check if daemon is already running
    if tailscale status >/dev/null 2>&1; then
        log "Tailscale daemon is already running"
        return 0
    fi

    # Try privileged mode first, fallback to userspace if fails
    tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
    local pid=$!
    sleep 2
    if ps -p $pid > /dev/null 2>&1 && tailscale status >/dev/null 2>&1; then
        log "Tailscale daemon started (kernel mode)"
        return 0
    fi
    
    warn "Kernel mode failed, cleaning up..."
    kill $pid 2>/dev/null || true
    rm -f /var/run/tailscale/tailscaled.sock

    # Fallback to userspace mode
    log "Falling back to userspace networking mode..."
    tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
    local pid2=$!
    sleep 3
    if ps -p $pid2 > /dev/null 2>&1 && tailscale status >/dev/null 2>&1; then
        log "Tailscale daemon started (userspace mode)"
        return 0
    else
        warn "Tailscale daemon failed to start (pid $pid2 died). Checking if daemon is actually working..."
        # Final check if daemon is actually running despite errors
        if tailscale status >/dev/null 2>&1; then
            log "✓ Tailscale daemon is running and responsive"
            return 0
        fi
        warn "All attempts to start Tailscale daemon had issues, but continuing..."
        return 1
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
    local provider="Unknown"
    local region=""
    
    # Try AWS metadata - get region and use that as provider
    if aws_region=$(curl -sf --max-time 2 http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null); then
        if [ -n "$aws_region" ]; then
            provider="AWS"
            region="$aws_region"
        fi
    fi
    
    # Try GCP metadata if AWS failed
    if [ "$provider" = "Unknown" ] && gcp_zone=$(curl -sf --max-time 2 -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone 2>/dev/null | awk -F/ '{print $4}'); then
        if [ -n "$gcp_zone" ]; then
            provider="GCP"
            region="$gcp_zone"
        fi
    fi
    
    # Try Azure metadata if previous failed
    if [ "$provider" = "Unknown" ] && az_region=$(curl -sf --max-time 2 -H "Metadata: true" "http://169.254.169.254/metadata/instance/compute/location?api-version=2021-02-01&format=text" 2>/dev/null); then
        if [ -n "$az_region" ]; then
            provider="Azure"
            region="$az_region"
        fi
    fi
    
    # Try ipinfo.io if none of the above work
    if [ "$provider" = "Unknown" ]; then
        # Get organization info with better parsing
        local org_info=$(curl -sf --max-time 4 https://ipinfo.io/org 2>/dev/null || echo "")
        if [ -n "$org_info" ]; then
            # Extract first meaningful word, clean it up
            local clean_org=$(echo "$org_info" | sed 's/^AS[0-9]*[[:space:]]*//' | sed 's/Internet[^ ]*//g' | sed 's/Services[^ ]*//g' | cut -d' ' -f1 | sed 's/[^a-zA-Z0-9]//g')
            if [ -n "$clean_org" ] && [ ${#clean_org} -ge 2 ]; then
                provider="$clean_org"
            else
                # Fallback to extracting from organization
                local first_part=$(echo "$org_info" | awk '{print $1}' | sed 's/[^a-zA-Z0-9]//g')
                if [ -n "$first_part" ]; then
                    provider="$first_part"
                fi
            fi
        fi
        
        # Also try to get region from ipinfo
        local region_info=$(curl -sf --max-time 3 https://ipinfo.io/region 2>/dev/null || echo "")
        if [ -n "$region_info" ]; then
            region=$(echo "$region_info" | tr '[:lower:]' '[:upper:]' | sed 's/[^a-zA-Z0-9]//g')
        fi
    fi
    
    # Final fallback if still Unknown
    [[ -z "$provider" || "$provider" == "Unknown" ]] && provider="Default"
    
    local result="$provider"
    [ -n "$region" ] && result="${provider}-${region}"
    
    # Cache the result
    echo "$result" > "$DATACENTER_INFO_FILE"
    
    # Return without any additional output
    echo "$result"
    return
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
    
    # Use full hostname format: Prefix-Datacenter-Country-Sequence
    local name=""
    if [ -n "$HOSTNAME_PREFIX" ] && [ -n "$datacenter" ]; then
        # Remove trailing dash from prefix and leading dash from datacenter
        local clean_prefix="${HOSTNAME_PREFIX%-}"
        local clean_datacenter="${datacenter#-}"
        name="${clean_prefix}-${clean_datacenter}-${country}-${sequence}"
    elif [ -n "$HOSTNAME_PREFIX" ]; then
        local clean_prefix="${HOSTNAME_PREFIX%-}"
        name="${clean_prefix}-${country}-${sequence}"
    else
        name="Unknown-${country}-${sequence}"
    fi
    
    # Clean up double dashes
    name=$(echo "$name" | sed 's/--/-/g')
    
    echo "$name"
}

# Connect to Tailscale
connect() {
    local hostname="$1"

    # Try as exit node (2 attempts)
    for i in 1 2; do
        if tailscale up --authkey="$AUTH_KEY" --hostname="$hostname" --advertise-exit-node --accept-routes --timeout=30s; then
            log "✓ Connected as exit node"
            return 0
        fi
        [ $i -eq 1 ] && sleep 2
    done

    # Fallback: regular mode
    warn "Exit node failed, connecting as regular client..."
    if tailscale up --authkey="$AUTH_KEY" --hostname="$hostname" --accept-routes --timeout=30s; then
        warn "Connected without exit node (approve manually in admin console)"
        return 0
    fi

    err "Connection failed"
}

# Cleanup on exit - only stop health server, keep Tailscale running
cleanup() {
    # Don't kill health server or stop Tailscale - let them run in background
    :
}
trap cleanup EXIT SIGTERM SIGINT

# Main
echo "=== Tailscale Auto-Setup (Docker) ==="

start_health
log "Health server started on port $HTTP_PORT"

start_daemon

# Setup exit node (with fallbacks for restricted environments)
log "Setting up exit node..."
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || \
  echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null || \
  log "IP forwarding unavailable (userspace mode)"
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || true
iptables -t nat -A POSTROUTING -s 100.64.0.0/10 -j MASQUERADE 2>/dev/null || true

COUNTRY=$(get_country)
DATACENTER=$(get_datacenter_info)
SEQUENCE=$(get_next_sequence "$HOSTNAME_PREFIX" "$COUNTRY" "$DATACENTER")
HOSTNAME=$(get_hostname "$COUNTRY" "$DATACENTER" "$SEQUENCE")

log "Country: $COUNTRY"
log "Datacenter: $DATACENTER"
log "Hostname: $HOSTNAME"

connect "$HOSTNAME"

# Get connection info even if status commands fail
TS_IP4=$(tailscale ip -4 2>/dev/null || echo "N/A")
TS_IP6=$(tailscale ip -6 2>/dev/null || echo "N/A")
PUBLIC_IP=$(curl -sf --max-time 3 ifconfig.me 2>/dev/null || echo "N/A")
NODES=$(tailscale status 2>/dev/null | grep -c "^[0-9]" || echo "0")
UPTIME=$(ps -p $$ -o etime= | tr -d ' ' || echo "N/A")
CONNECTION_STATUS=$(tailscale status 2>/dev/null | head -1 || echo "NeedsApproval")

echo ""
echo -e "\033[1;32m╔═══════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;32m║              ✓  TAILSCALE CONNECTION ESTABLISHED           ║\033[0m"
echo -e "\033[1;32m╚═══════════════════════════════════════════════════════════╝\033[0m"
echo ""
echo -e "\033[1;37m┌───────────────────┬──────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;37m│\033[0m \033[1;36mParameter\033[0m         \033[1;37m│\033[0m \033[1;33mValue\033[0m                                                \033[1;37m│\033[0m"
echo -e "\033[1;37m├───────────────────┼──────────────────────────────────────────────────────┤\033[0m"
echo -e "\033[1;37m│\033[0m Hostname          \033[1;37m│\033[0m \033[1;33m$HOSTNAME\033[0m"
echo -e "\033[1;37m│\033[0m Tailscale IPv4    \033[1;37m│\033[0m \033[1;32m$TS_IP4\033[0m"
echo -e "\033[1;37m│\033[0m Tailscale IPv6    \033[1;37m│\033[0m \033[0;90m$TS_IP6\033[0m"
echo -e "\033[1;37m│\033[0m Public IP         \033[1;37m│\033[0m \033[0;37m$PUBLIC_IP\033[0m"
echo -e "\033[1;37m│\033[0m Location          \033[1;37m│\033[0m \033[1;35m$DATACENTER\033[0m"
echo -e "\033[1;37m│\033[0m Country           \033[1;37m│\033[0m \033[1;35m$COUNTRY\033[0m"
echo -e "\033[1;37m│\033[0m Connection Status \033[1;37m│\033[0m \033[1;33m$CONNECTION_STATUS\033[0m"
echo -e "\033[1;37m│\033[0m Exit Node         \033[1;37m│\033[0m \033[1;31mAdvertised (Approve in Admin Panel)\033[0m"
echo -e "\033[1;37m│\033[0m Network Nodes     \033[1;37m│\033[0m \033[1;36m$NODES\033[0m"
echo -e "\033[1;37m│\033[0m Uptime            \033[1;37m│\033[0m \033[0;37m$UPTIME\033[0m"
echo -e "\033[1;37m└───────────────────┴──────────────────────────────────────────────────────┘\033[0m"
echo ""
echo -e "\033[1;34m🔗 Admin Panel:\033[0m \033[4;36mhttps://login.tailscale.com/admin/machines\033[0m"
echo -e "\033[1;34m📊 Health Check:\033[0m \033[4;36mhttp://localhost:$HTTP_PORT\033[0m"
echo -e "\033[1;33m⚠️  Action Required:\033[0m \033[1;37mApprove this device in the Tailscale Admin Panel\033[0m"
echo ""

# Give a moment for all processes to settle before script exits
sleep 2
log "✓ Tailscale setup complete - services running in background"
