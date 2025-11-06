#!/bin/bash

# ============================================================================
# Universal Startup Script for Tailscale Exit Node
# ============================================================================
# This script works across all platforms: Codespaces, Render, Fly.io, etc.
# All logs are written to STDOUT/STDERR for visibility
# ============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&1
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $*" >&1
}

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️  $*" >&1
}

log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $*" >&1
}

# ============================================================================
# STARTUP BANNER
# ============================================================================

log "============================================"
log "  Tailscale Exit Node - Starting..."
log "============================================"
log ""

# ============================================================================
# ENVIRONMENT DETECTION
# ============================================================================

log_info "Detecting runtime environment..."

if [ -n "${CODESPACES:-}" ]; then
    PLATFORM="Codespaces"
    log_success "Running on GitHub Codespaces"
elif [ -n "${RENDER:-}" ]; then
    PLATFORM="Render"
    log_success "Running on Render.com"
elif [ -n "${FLY_APP_NAME:-}" ]; then
    PLATFORM="Fly.io"
    log_success "Running on Fly.io"
elif [ -n "${RAILWAY_ENVIRONMENT:-}" ]; then
    PLATFORM="Railway"
    log_success "Running on Railway"
elif [ -n "${KOYEB_DEPLOYMENT_ID:-}" ]; then
    PLATFORM="Koyeb"
    log_success "Running on Koyeb"
else
    PLATFORM="Unknown"
    log_info "Platform not detected, proceeding with generic setup"
fi

log ""

# ============================================================================
# CONFIGURATION
# ============================================================================

log_info "Loading configuration..."

# Required variables
TAILSCALE_AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"

# Optional variables with defaults
HTTP_PORT="${HTTP_PORT:-8080}"
ENABLE_LOGGING="${ENABLE_LOGGING:-true}"
MAX_RETRIES="${MAX_RETRIES:-5}"
COUNTRY_LOOKUP_TIMEOUT="${COUNTRY_LOOKUP_TIMEOUT:-5}"
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-}"
COUNTRY_CODE_OVERRIDE="${COUNTRY_CODE_OVERRIDE:-}"

# ============================================================================
# VALIDATION
# ============================================================================

log_info "Validating configuration..."

if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    log_error "TAILSCALE_AUTH_KEY is not set!"
    log_error ""
    log_error "Please set the environment variable:"
    log_error "  export TAILSCALE_AUTH_KEY='tskey-auth-xxxxxxxxxxxxx'"
    log_error ""
    log_error "Or create a .env file with:"
    log_error "  TAILSCALE_AUTH_KEY=tskey-auth-xxxxxxxxxxxxx"
    log_error ""
    exit 1
fi

if [[ ! "$TAILSCALE_AUTH_KEY" =~ ^tskey-auth- ]]; then
    log_warning "AUTH_KEY doesn't start with 'tskey-auth-', this might be incorrect"
fi

log_success "Configuration validated"
log ""

# ============================================================================
# SYSTEM CHECKS
# ============================================================================

log_info "Performing system checks..."

# Check if running as root (required for Tailscale)
if [ "$(id -u)" -ne 0 ]; then
    log_warning "Not running as root, some operations may fail"
fi

# Check if Tailscale is installed
if ! command -v tailscale &> /dev/null; then
    log_error "Tailscale is not installed!"
    log_error "This should have been installed during container build"
    exit 1
fi

log_success "Tailscale is installed: $(tailscale version)"

# Check if TUN device exists
if [ ! -e /dev/net/tun ]; then
    log_warning "/dev/net/tun not found!"
    log_warning "Attempting to create it..."
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200 2>/dev/null || log_warning "Could not create /dev/net/tun"
fi

if [ -e /dev/net/tun ]; then
    log_success "/dev/net/tun is available"
else
    log_error "/dev/net/tun is not available - Tailscale will likely fail"
fi

log ""

# ============================================================================
# COUNTRY DETECTION
# ============================================================================

log_info "Detecting server location..."

if [ -n "$COUNTRY_CODE_OVERRIDE" ]; then
    COUNTRY_CODE="$COUNTRY_CODE_OVERRIDE"
    log_info "Using override country code: $COUNTRY_CODE"
else
    COUNTRY_CODE=$(timeout "$COUNTRY_LOOKUP_TIMEOUT" curl -s https://ipapi.co/country/ 2>/dev/null || echo "XX")

    if [ "$COUNTRY_CODE" = "XX" ]; then
        log_warning "Could not detect country, using default: XX"
    else
        log_success "Detected country: $COUNTRY_CODE"
    fi
fi

# ============================================================================
# HOSTNAME GENERATION
# ============================================================================

log_info "Generating hostname..."

if [ -n "$HOSTNAME_PREFIX" ]; then
    BASE_HOSTNAME="$HOSTNAME_PREFIX"
else
    BASE_HOSTNAME="$COUNTRY_CODE"
fi

# Generate unique suffix based on platform-specific identifiers
if [ "$PLATFORM" = "Codespaces" ]; then
    UNIQUE_ID="${CODESPACE_NAME:-$(hostname)}"
elif [ "$PLATFORM" = "Render" ]; then
    UNIQUE_ID="${RENDER_SERVICE_ID:-$(hostname)}"
elif [ "$PLATFORM" = "Fly.io" ]; then
    UNIQUE_ID="${FLY_ALLOC_ID:-$(hostname)}"
else
    UNIQUE_ID="$(hostname)"
fi

# Create short hash from unique ID
SHORT_HASH=$(echo -n "$UNIQUE_ID" | md5sum | cut -c1-4)
HOSTNAME="$BASE_HOSTNAME-$SHORT_HASH"

log_success "Hostname will be: $HOSTNAME"
log ""

# ============================================================================
# START TAILSCALED DAEMON
# ============================================================================

log_info "Starting Tailscale daemon..."

# Start tailscaled in background
tailscaled --state=mem: --socket=/var/run/tailscale/tailscaled.sock &
TAILSCALED_PID=$!

log_success "Tailscaled started (PID: $TAILSCALED_PID)"

# Wait for socket to be ready
log_info "Waiting for Tailscale daemon to initialize..."
for i in {1..30}; do
    if [ -S /var/run/tailscale/tailscaled.sock ]; then
        log_success "Tailscale daemon is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        log_error "Tailscale daemon failed to start!"
        exit 1
    fi
    sleep 1
done

log ""

# ============================================================================
# CONNECT TO TAILSCALE
# ============================================================================

log_info "Connecting to Tailscale network..."
log_info "Hostname: $HOSTNAME"
log_info "Exit node: ENABLED"
log_info "SSH: ENABLED"

tailscale up \
    --authkey="$TAILSCALE_AUTH_KEY" \
    --hostname="$HOSTNAME" \
    --advertise-exit-node \
    --ssh \
    --accept-routes \
    --reset

if [ $? -eq 0 ]; then
    log_success "Successfully connected to Tailscale!"
else
    log_error "Failed to connect to Tailscale"
    exit 1
fi

log ""

# ============================================================================
# DISPLAY STATUS
# ============================================================================

log_info "Tailscale Status:"
tailscale status || true

log ""
log_info "Tailscale IP addresses:"
tailscale ip -4 2>/dev/null || log_warning "Could not get IPv4 address"
tailscale ip -6 2>/dev/null || log_warning "Could not get IPv6 address"

log ""

# ============================================================================
# HEALTH CHECK SERVER
# ============================================================================

log_info "Starting health check server on port $HTTP_PORT..."

# Simple HTTP server using netcat
while true; do
    {
        echo -e "HTTP/1.1 200 OK\r"
        echo -e "Content-Type: application/json\r"
        echo -e "Connection: close\r"
        echo -e "\r"
        echo -e "{"
        echo -e "  \"status\": \"healthy\","
        echo -e "  \"platform\": \"$PLATFORM\","
        echo -e "  \"hostname\": \"$HOSTNAME\","
        echo -e "  \"country\": \"$COUNTRY_CODE\","
        echo -e "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
        echo -e "}"
    } | nc -l -p "$HTTP_PORT" -q 1 2>/dev/null
done &

HEALTH_SERVER_PID=$!

log_success "Health check server started (PID: $HEALTH_SERVER_PID)"
log_info "Access health endpoint at: http://localhost:$HTTP_PORT/health"

log ""

# ============================================================================
# READY
# ============================================================================

log "============================================"
log_success "Tailscale Exit Node is RUNNING!"
log "============================================"
log ""
log_info "Platform: $PLATFORM"
log_info "Hostname: $HOSTNAME"
log_info "Country: $COUNTRY_CODE"
log_info "Exit Node: ✅ ENABLED"
log_info "SSH: ✅ ENABLED"
log ""
log_info "Next steps:"
log_info "1. Approve exit node at: https://login.tailscale.com/admin/machines"
log_info "2. Use this node as exit node from any device"
log ""
log "============================================"
log ""

# ============================================================================
# KEEP ALIVE & MONITORING
# ============================================================================

log_info "Monitoring services..."
log ""

# Function to check if process is running
check_process() {
    local pid=$1
    local name=$2

    if ! kill -0 "$pid" 2>/dev/null; then
        log_error "$name (PID: $pid) has stopped!"
        return 1
    fi
    return 0
}

# Main monitoring loop
while true; do
    sleep 30

    # Check tailscaled
    if ! check_process "$TAILSCALED_PID" "tailscaled"; then
        log_error "Tailscaled died, exiting..."
        exit 1
    fi

    # Check health server
    if ! check_process "$HEALTH_SERVER_PID" "health-server"; then
        log_warning "Health server died, restarting..."
        while true; do
            {
                echo -e "HTTP/1.1 200 OK\r"
                echo -e "Content-Type: application/json\r"
                echo -e "Connection: close\r"
                echo -e "\r"
                echo -e "{"
                echo -e "  \"status\": \"healthy\","
                echo -e "  \"platform\": \"$PLATFORM\","
                echo -e "  \"hostname\": \"$HOSTNAME\","
                echo -e "  \"country\": \"$COUNTRY_CODE\","
                echo -e "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
                echo -e "}"
            } | nc -l -p "$HTTP_PORT" -q 1 2>/dev/null
        done &
        HEALTH_SERVER_PID=$!
        log_success "Health server restarted (PID: $HEALTH_SERVER_PID)"
    fi

    # Log status update
    if [ "$ENABLE_LOGGING" = "true" ]; then
        log_info "Status check: tailscaled (PID: $TAILSCALED_PID) ✅, health-server (PID: $HEALTH_SERVER_PID) ✅"
    fi
done
