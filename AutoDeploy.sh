#!/bin/bash

# Simple Tailscale Auto-Setup - Minimal Version
echo "=== Starting Tailscale Auto-Setup ==="

# Simple logging
log() { echo "$(date '+%H:%M:%S') $1"; }

# Get auth key directly from environment - try multiple sources
AUTH_KEY="${TAILSCALE_AUTH_KEY}"
if [ -z "$AUTH_KEY" ]; then
    # Fallback to check render environment variables directly
    log "AutoDeploy: TAILSCALE_AUTH_KEY not found, checking environment..."
    log "AutoDeploy: ENV vars starting with TAILSCALE:"
    env | grep TAILSCALE | grep -v AUTH || true
    echo "ERROR: TAILSCALE_AUTH_KEY not set in AutoDeploy"
    exit 1
fi

# Enhanced debugging - show what's actually in the AUTH_KEY variable
log "AutoDeploy: AUTH_KEY found via environment"
log "AutoDeploy: Raw AUTH_KEY length: ${#AUTH_KEY}"
log "AutoDeploy: Raw AUTH_KEY first 20 chars: '${AUTH_KEY:0:20}'"
log "AutoDeploy: Raw AUTH_KEY last 10 chars: '${AUTH_KEY: -10}'"

# Check if AUTH_KEY is getting truncated by environment variable processing
if [ "${#AUTH_KEY}" -ne 61 ]; then
    log "AutoDeploy: WARNING - Auth key length ${#AUTH_KEY} is not expected 61 characters!"
    log "AutoDeploy: This suggests the key was truncated during processing"
else
    log "AutoDeploy: Auth key length is correct (61 characters)"
fi

# Start health server using external Python script
PORT="${PORT:-10000}"
log "Starting health server on port $PORT"

# Use the external health server script
if [ -f "/healthApi.py" ] && command -v python3 >/dev/null 2>&1; then
    # Use external Python health server
    export PORT=$PORT
    python3 /healthApi.py &
    HEALTH_PID=$!
    log "Health server started with external script (PID: $HEALTH_PID)"
else
    # Fallback to built-in Python without external file
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import socket
import threading
import time
import os
import signal
import sys

class HealthServer:
    def __init__(self, port=10000):
        self.port = port
        self.sock = None
        
    def handle_client(self, conn, addr):
        try:
            data = conn.recv(1024).decode()
            if 'GET /health' in data:
                response = 'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 15\r\n\r\n{\"status\":\"ok\"}'
                conn.send(response.encode())
            else:
                conn.send('HTTP/1.1 404 Not Found\r\n\r\n'.encode())
        except:
            pass
        finally:
            conn.close()
            
    def start(self):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind(('0.0.0.0', self.port))
            sock.listen(5)
            
            while True:
                try:
                    conn, addr = sock.accept()
                    threading.Thread(target=self.handle_client, args=(conn, addr)).start()
                except:
                    time.sleep(1)
        except Exception as e:
            print(f'Health server error: {e}')
            time.sleep(60)
        finally:
            if 'sock' in locals():
                sock.close()

try:
    port = int(os.environ.get('PORT', '10000'))
    server = HealthServer(port)
    server.start()
except KeyboardInterrupt:
    print('Health server stopping...')
" &
        HEALTH_PID=$!
        log "Health server started with builtin Python (PID: $HEALTH_PID)"
    else
        log "Warning: Python3 not available, health server not started"
        HEALTH_PID=""
    fi
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

# Get hostname components
HOSTNAME_PREFIX="${HOSTNAME_PREFIX:-erf}" # Default to 'erf' if not set
IP_INFO=$(curl -sf --max-time 2 https://ipinfo.io/json 2>/dev/null)

COUNTRY=$(echo "$IP_INFO" | jq -r '.country // "XX"' 2>/dev/null)
REGION=$(echo "$IP_INFO" | jq -r '.region // "UnknownRegion"' 2>/dev/null)
ORG=$(echo "$IP_INFO" | jq -r '.org // "UnknownProvider"' 2>/dev/null)

# Sanitize strings for hostname
# Replace non-alphanumeric characters with a single hyphen, convert to lowercase, and remove leading/trailing hyphens
REGION_SANITIZED=$(echo "$REGION" | sed -E 's/[^a-zA-Z0-9]+/-/g' | tr '[:upper:]' '[:lower:]' | sed -E 's/^-+|-+$//g')
ORG_SANITIZED=$(echo "$ORG" | sed -E 's/[^a-zA-Z0-9]+/-/g' | tr '[:upper:]' '[:lower:]' | sed -E 's/^-+|-+$//g')

# Use default if sanitized values are empty
REGION_SANITIZED="${REGION_SANITIZED:-unknown-region}"
ORG_SANITIZED="${ORG_SANITIZED:-unknown-provider}"

SEQUENCE=$(cat /tmp/count 2>/dev/null || echo "1")
echo $((SEQUENCE + 1)) > /tmp/count

# Generate hostname
HOSTNAME="${HOSTNAME_PREFIX}-${ORG_SANITIZED}-${REGION_SANITIZED}-${COUNTRY}-${SEQUENCE}"

# Connect to Tailscale - try multiple authentication methods
log "AutoDeploy: Starting authentication process..."

# Method 1: Create a pre-authenticated auth state
log "AutoDeploy: Attempting pre-authentication method..."
TS_AUTHKEY="$AUTH_KEY" tailscale up --hostname="$HOSTNAME" --advertise-exit-node --accept-routes --operator="$USER" 2>&1 | tee /tmp/tailscale_auth.log

if [ $? -eq 0 ]; then
    log "Authentication successful with pre-authentication method!"
else
    log "Pre-authentication failed, checking detailed output..."
    
    # Method 2: Try using the key with explicit environment variable
    log "AutoDeploy: Trying explicit environment variable method..."
    export TAILSCALE_AUTH_KEY="$AUTH_KEY"
    tailscale up --authkey="$AUTH_KEY" --hostname="$HOSTNAME" --advertise-exit-node --accept-routes 2>&1 | tee /tmp/tailscale_auth2.log
    
    if [ $? -eq 0 ]; then
        log "Authentication successful with environment variable method!"
    else
        # Method 3: Try a simplified approach
        log "AutoDeploy: Trying simplified direct key method..."
        tailscale up --accept-routes 2>&1 | tee /tmp/tailscale_auth3.log
        
        if [ $? -eq 0 ]; then
            log "Authentication successful with simplified method!"
        else
            # Method 4: Use web authentication as fallback
            log "AutoDeploy: Warning - Using web authentication fallback..."
            tailscale up --hostname="$HOSTNAME" --advertise-exit-node --accept-routes 2>&1 | tee /tmp/tailscale_web_auth.log
            if [ $? -ne 0 ]; then
                log "Authentication failed - service will run without Tailscale VPN"
            fi
        fi
    fi
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
