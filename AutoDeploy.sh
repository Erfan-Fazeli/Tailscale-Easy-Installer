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
