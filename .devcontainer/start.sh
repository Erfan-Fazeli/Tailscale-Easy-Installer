#!/bin/bash

# ============================================================================
# Tailscale Auto-Installer & Exit Node Setup
# Multi-Platform Support: Codespaces, Render, Fly.io, Koyeb, Railway, etc.
# ============================================================================

set -e  # Exit on error
set -o pipefail  # Catch errors in pipes

# ============================================================================
# CONFIGURATION - Read from Environment Variables
# ============================================================================

AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-}"
COUNTRY_CODE_OVERRIDE="${COUNTRY_CODE_OVERRIDE:-}"
HTTP_PORT="${HTTP_PORT:-8080}"
ENABLE_LOGGING="${ENABLE_LOGGING:-true}"
MAX_RETRIES="${MAX_RETRIES:-5}"
COUNTRY_LOOKUP_TIMEOUT="${COUNTRY_LOOKUP_TIMEOUT:-5}"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    if [ "$ENABLE_LOGGING" = "true" ]; then
        echo "[INFO] $1"
    fi
}

log_success() {
    echo "[SUCCESS] ✓ $1"
}

log_error() {
    echo "[ERROR] ✗ $1" >&2
}

log_warning() {
    echo "[WARNING] ⚠ $1"
}

# ============================================================================
# PLATFORM DETECTION
# ============================================================================
# Detects the hosting platform to adjust behavior accordingly.
# - Codespaces: Exits after setup to save usage hours (limited monthly quota)
# - Other platforms: Keeps container running 24/7 with health server

detect_platform() {
    log_info "Detecting platform..."

    if [ "$CODESPACES" = "true" ]; then
        echo "codespaces"
    elif [ -n "$RENDER" ]; then
        echo "render"
    elif [ -n "$FLY_APP_NAME" ]; then
        echo "fly"
    elif [ -n "$KOYEB_APP" ]; then
        echo "koyeb"
    elif [ -n "$RAILWAY_ENVIRONMENT" ]; then
        echo "railway"
    else
        echo "docker"
    fi
}

PLATFORM=$(detect_platform)
log_success "Platform detected: $PLATFORM"

# ============================================================================
# VALIDATION
# ============================================================================

validate_config() {
    log_info "Validating configuration..."

    if [ -z "$AUTH_KEY" ]; then
        log_error "TAILSCALE_AUTH_KEY is not set!"
        log_error "Please set the TAILSCALE_AUTH_KEY environment variable."
        log_error "Generate one at: https://login.tailscale.com/admin/settings/keys"
        exit 1
    fi

    if [[ ! "$AUTH_KEY" =~ ^tskey-auth- ]]; then
        log_error "Invalid AUTH_KEY format. Must start with 'tskey-auth-'"
        exit 1
    fi

    log_success "Configuration validated"
}

validate_config

# ============================================================================
# HTTP HEALTH SERVER (Background Process)
# ============================================================================

start_health_server() {
    log_info "Starting HTTP health server on port $HTTP_PORT..."

    # Create a simple HTTP server using netcat
    while true; do
        {
            echo -e "HTTP/1.1 200 OK\r"
            echo -e "Content-Type: application/json\r"
            echo -e "Connection: close\r"
            echo -e "\r"
            echo -n '{"status":"healthy","platform":"'"$PLATFORM"'","tailscale":"'
            if sudo tailscale status --json >/dev/null 2>&1; then
                TAILSCALE_IP=$(sudo tailscale ip -4 2>/dev/null || echo "pending")
                HOSTNAME=$(sudo tailscale status --json 2>/dev/null | jq -r '.Self.HostName' || echo "pending")
                echo -n 'connected","ip":"'"$TAILSCALE_IP"'","hostname":"'"$HOSTNAME"'"}'
            else
                echo -n 'connecting"}'
            fi
        } | nc -l -p "$HTTP_PORT" -q 1 >/dev/null 2>&1 || true
    done &

    HEALTH_PID=$!
    log_success "Health server started (PID: $HEALTH_PID)"
}

# ============================================================================
# TAILSCALE DAEMON SETUP
# ============================================================================

start_tailscale_daemon() {
    log_info "Starting Tailscale daemon..."

    # Start tailscaled in background
    sudo tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
    TAILSCALED_PID=$!

    # Wait for daemon to be ready
    for i in {1..30}; do
        if sudo tailscale status >/dev/null 2>&1; then
            log_success "Tailscale daemon is ready"
            return 0
        fi
        sleep 1
    done

    log_error "Tailscale daemon failed to start"
    exit 1
}

# ============================================================================
# IP FORWARDING (Required for Exit Node)
# ============================================================================

enable_ip_forwarding() {
    log_info "Enabling IP forwarding for exit node..."

    sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || log_warning "IPv4 forwarding may not be enabled"
    sudo sysctl -w net.ipv6.conf.all.forwarding=1 >/dev/null 2>&1 || log_warning "IPv6 forwarding may not be enabled"

    log_success "IP forwarding configured"
}

# ============================================================================
# COUNTRY CODE DETECTION (with Multiple Fallbacks)
# ============================================================================

detect_country() {
    if [ -n "$COUNTRY_CODE_OVERRIDE" ]; then
        log_info "Using override country code: $COUNTRY_CODE_OVERRIDE"
        echo "$COUNTRY_CODE_OVERRIDE"
        return 0
    fi

    log_info "Detecting country from public IP..."

    # Try multiple services with fallback
    local country=""

    # Try ipinfo.io
    country=$(curl -s --max-time "$COUNTRY_LOOKUP_TIMEOUT" https://ipinfo.io/country 2>/dev/null | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    if [ -n "$country" ] && [ ${#country} -eq 2 ]; then
        log_success "Country detected: $country (via ipinfo.io)"
        echo "$country"
        return 0
    fi

    # Try ipapi.co
    country=$(curl -s --max-time "$COUNTRY_LOOKUP_TIMEOUT" https://ipapi.co/country 2>/dev/null | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    if [ -n "$country" ] && [ ${#country} -eq 2 ]; then
        log_success "Country detected: $country (via ipapi.co)"
        echo "$country"
        return 0
    fi

    # Try ifconfig.co
    country=$(curl -s --max-time "$COUNTRY_LOOKUP_TIMEOUT" https://ifconfig.co/country-iso 2>/dev/null | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    if [ -n "$country" ] && [ ${#country} -eq 2 ]; then
        log_success "Country detected: $country (via ifconfig.co)"
        echo "$country"
        return 0
    fi

    # Fallback
    log_warning "Country detection failed, using 'XX'"
    echo "XX"
}

# ============================================================================
# GENERATE UNIQUE HOSTNAME
# ============================================================================

generate_hostname() {
    local country="$1"

    log_info "Generating unique hostname..."

    # Get list of existing hostnames for this country
    local existing_numbers=$(sudo tailscale status --json 2>/dev/null | \
        jq -r '.Peer | to_entries[] | .value.HostName' 2>/dev/null | \
        grep -E "^${HOSTNAME_PREFIX:+${HOSTNAME_PREFIX}-}${country}-[0-9]+$" | \
        sed "s/^${HOSTNAME_PREFIX:+${HOSTNAME_PREFIX}-}${country}-//g" | \
        sort -n || echo "")

    # Find highest number
    local last_num=0
    if [ -n "$existing_numbers" ]; then
        last_num=$(echo "$existing_numbers" | tail -n 1)
    fi

    # Calculate next number
    local next_num=$((last_num + 1))

    # Construct hostname
    local hostname="${country}-${next_num}"
    if [ -n "$HOSTNAME_PREFIX" ]; then
        hostname="${HOSTNAME_PREFIX}-${hostname}"
    fi

    log_success "Generated hostname: $hostname"
    echo "$hostname"
}

# ============================================================================
# TAILSCALE CONNECTION (with Retry Logic)
# ============================================================================

connect_tailscale() {
    local hostname="$1"
    local retry=0

    log_info "Connecting to Tailscale as exit node..."

    while [ $retry -lt "$MAX_RETRIES" ]; do
        log_info "Connection attempt $((retry + 1))/$MAX_RETRIES..."

        if sudo tailscale up \
            --authkey="$AUTH_KEY" \
            --hostname="$hostname" \
            --advertise-exit-node \
            --accept-routes \
            --timeout=30s; then

            log_success "Successfully connected to Tailscale!"

            # Wait for network to stabilize
            sleep 3

            # Display connection info
            local tailscale_ip=$(sudo tailscale ip -4 2>/dev/null || echo "pending")
            log_success "Tailscale IP: $tailscale_ip"
            log_success "Hostname: $hostname"
            log_success "Exit node: ADVERTISED (needs approval in admin panel)"

            return 0
        fi

        retry=$((retry + 1))
        if [ $retry -lt "$MAX_RETRIES" ]; then
            local wait_time=$((2 ** retry))  # Exponential backoff
            log_warning "Connection failed, retrying in ${wait_time}s..."
            sleep "$wait_time"
        fi
    done

    log_error "Failed to connect to Tailscale after $MAX_RETRIES attempts"
    return 1
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo "============================================"
    echo "  Tailscale Auto-Installer v4.0"
    echo "  Platform: $PLATFORM"
    echo "============================================"
    echo

    # Start health server first (for platforms that need immediate response)
    start_health_server

    # Start Tailscale daemon
    start_tailscale_daemon

    # Enable IP forwarding
    enable_ip_forwarding

    # Detect country
    COUNTRY_CODE=$(detect_country)

    # Generate hostname
    HOSTNAME=$(generate_hostname "$COUNTRY_CODE")

    # Connect to Tailscale with retry logic
    if ! connect_tailscale "$HOSTNAME"; then
        log_error "Setup failed!"
        exit 1
    fi

    echo
    echo "============================================"
    echo "  Setup Complete!"
    echo "============================================"
    echo "  Hostname: $HOSTNAME"
    echo "  Platform: $PLATFORM"
    echo "  Health Check: http://localhost:$HTTP_PORT"
    echo "============================================"
    echo

    # ========================================================================
    # KEEP-ALIVE STRATEGY (Platform-Specific)
    # ========================================================================
    # Codespaces: Exit after setup to conserve limited monthly usage hours.
    #             Tailscale daemon continues running in background.
    #             Container auto-stops when idle, saving costs.
    #
    # Other platforms: Keep container alive indefinitely with 'wait'.
    #                  Health server prevents idle shutdown on free tiers.
    # ========================================================================

    if [ "$PLATFORM" = "codespaces" ]; then
        log_info "Codespaces detected - setup complete, container will auto-stop when idle"
        log_info "Tailscale will remain connected in the background"
        log_info "This saves your limited monthly Codespaces hours"
        # Exit gracefully - Codespaces will keep the container running as needed
        exit 0
    else
        log_info "Keeping container alive for platform: $PLATFORM"
        log_info "Health server running on port $HTTP_PORT"
        wait
    fi
}

# ============================================================================
# TRAP SIGNALS FOR GRACEFUL SHUTDOWN
# ============================================================================

cleanup() {
    log_info "Shutting down gracefully..."
    sudo tailscale down 2>/dev/null || true
    kill $HEALTH_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGTERM SIGINT

# ============================================================================
# RUN MAIN
# ============================================================================

main
