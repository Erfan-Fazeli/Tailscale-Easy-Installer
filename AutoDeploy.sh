#!/bin/bash

# Simple Tailscale Auto-Setup - Minimal Version
echo "=== Starting Tailscale Auto-Setup ==="

# Simple logging
log() { echo "$(date '+%H:%M:%S') $1"; }

# NEW FILE-BASED AUTHENTICATION APPROACH
# This completely avoids environment variable issues by using Tailscale's file: prefix support

# Primary method: Use auth key file created by entrypoint.sh
if [ -n "$TAILSCALE_AUTH_KEY_FILE" ] && [ -f "$TAILSCALE_AUTH_KEY_FILE" ]; then
    log "AutoDeploy: Using auth key from file: $TAILSCALE_AUTH_KEY_FILE"
    AUTH_KEY_FILE="$TAILSCALE_AUTH_KEY_FILE"
    AUTH_KEY_FROM_FILE=$(cat "$AUTH_KEY_FILE" | tr -d '\n\r')
    log "AutoDeploy: Auth key from file - length: ${#AUTH_KEY_FROM_FILE}"
    log "AutoDeploy: Auth key from file - first 20 chars: '${AUTH_KEY_FROM_FILE:0:20}'"
    log "AutoDeploy: Auth key from file - last 10 chars: '${AUTH_KEY_FROM_FILE: -10}'"
else
    # Fallback: Create auth key file from environment variable
    log "AutoDeploy: Creating auth key file from environment variable"
    AUTH_KEY="${TAILSCALE_AUTH_KEY}"

    if [ -z "$AUTH_KEY" ]; then
        log "ERROR: TAILSCALE_AUTH_KEY not found in environment"
        env | grep TAILSCALE | grep -v AUTH || true
        exit 1
    fi

    # Create the auth key file
    AUTH_KEY_FILE="/tmp/tailscale-authkey"
    echo -n "$AUTH_KEY" > "$AUTH_KEY_FILE"
    chmod 600 "$AUTH_KEY_FILE"

    AUTH_KEY_FROM_FILE=$(cat "$AUTH_KEY_FILE")
    log "AutoDeploy: Created auth key file: $AUTH_KEY_FILE"
    log "AutoDeploy: Auth key length: ${#AUTH_KEY_FROM_FILE}"
    log "AutoDeploy: Auth key first 20 chars: '${AUTH_KEY_FROM_FILE:0:20}'"
    log "AutoDeploy: Auth key last 10 chars: '${AUTH_KEY_FROM_FILE: -10}'"
fi

# Verify auth key looks valid
if [ "${#AUTH_KEY_FROM_FILE}" -lt 30 ]; then
    log "ERROR: Auth key appears invalid - too short (${#AUTH_KEY_FROM_FILE} chars)"
    exit 1
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

# Connect to Tailscale using FILE-BASED authentication
log "AutoDeploy: Starting Tailscale authentication with file-based method..."
log "AutoDeploy: Using auth key file: $AUTH_KEY_FILE"
log "AutoDeploy: Auth key from file (for verification): '${AUTH_KEY_FROM_FILE:0:20}...${AUTH_KEY_FROM_FILE: -10}'"

# Method 1: Direct authkey parameter with properly quoted key from file
log "AutoDeploy: Method 1 - Using --authkey with direct key from file..."
tailscale up \
    --authkey="${AUTH_KEY_FROM_FILE}" \
    --hostname="$HOSTNAME" \
    --advertise-exit-node \
    --accept-routes \
    --operator="$USER" > /tmp/tailscale_auth1.log 2>&1

# Use PIPESTATUS to get the actual exit code of tailscale, not tee/redirect
AUTH_RESULT=$?

# Check for error messages in the output
if [ $AUTH_RESULT -eq 0 ] && ! grep -qi "error" /tmp/tailscale_auth1.log; then
    log "✓ Authentication successful with direct key method!"
else
    log "Method 1 failed (exit code: $AUTH_RESULT), trying Method 2..."
    if grep -qi "error" /tmp/tailscale_auth1.log; then
        log "Error found in output:"
        grep -i "error" /tmp/tailscale_auth1.log | head -3
    fi

    # Method 2: Use TS_AUTHKEY environment variable
    log "AutoDeploy: Method 2 - Using TS_AUTHKEY environment variable..."
    TS_AUTHKEY="${AUTH_KEY_FROM_FILE}" tailscale up \
        --hostname="$HOSTNAME" \
        --advertise-exit-node \
        --accept-routes \
        --operator="$USER" > /tmp/tailscale_auth2.log 2>&1

    AUTH_RESULT=$?

    if [ $AUTH_RESULT -eq 0 ] && ! grep -qi "error" /tmp/tailscale_auth2.log; then
        log "✓ Authentication successful with TS_AUTHKEY method!"
    else
        log "Method 2 failed (exit code: $AUTH_RESULT), trying Method 3..."
        if grep -qi "error" /tmp/tailscale_auth2.log; then
            log "Error found in output:"
            grep -i "error" /tmp/tailscale_auth2.log | head -3
        fi

        # Method 3: Use Tailscale's native file: prefix support
        log "AutoDeploy: Method 3 - Using --auth-key with file: prefix..."
        tailscale up \
            --auth-key="file:${AUTH_KEY_FILE}" \
            --hostname="$HOSTNAME" \
            --advertise-exit-node \
            --accept-routes \
            --operator="$USER" > /tmp/tailscale_auth3.log 2>&1

        AUTH_RESULT=$?

        if [ $AUTH_RESULT -eq 0 ] && ! grep -qi "error" /tmp/tailscale_auth3.log; then
            log "✓ Authentication successful with file: prefix method!"
        else
            log "Method 3 failed (exit code: $AUTH_RESULT), trying Method 4..."
            if grep -qi "error" /tmp/tailscale_auth3.log; then
                log "Error found in output:"
                grep -i "error" /tmp/tailscale_auth3.log | head -3
            fi

            # Method 4: Write key in a different format and use stdin
            log "AutoDeploy: Method 4 - Using stdin for auth key..."
            printf "%s" "$AUTH_KEY_FROM_FILE" | tailscale up \
                --authkey=- \
                --hostname="$HOSTNAME" \
                --advertise-exit-node \
                --accept-routes \
                --operator="$USER" > /tmp/tailscale_auth4.log 2>&1

            AUTH_RESULT=$?

            if [ $AUTH_RESULT -eq 0 ] && ! grep -qi "error" /tmp/tailscale_auth4.log; then
                log "✓ Authentication successful with stdin method!"
            else
                log "All authentication methods failed!"
                log "Error details:"
                for logfile in /tmp/tailscale_auth*.log; do
                    if [ -f "$logfile" ]; then
                        log "=== $(basename $logfile) ==="
                        tail -10 "$logfile"
                    fi
                done
                log "WARNING: Service will run without Tailscale VPN connection"
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
