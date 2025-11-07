#!/usr/bin/env bash

# Simple HTTP server using netcat/curl for /health endpoint
# This method doesn't require Python and works in minimal containers

PORT=${PORT:-${HTTP_PORT:-8080}}

echo "Starting health server on port $PORT"

# Create a simple HTTP response function
health_response() {
    cat <<EOF
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 15
Connection: close

{"status":"ok"}
EOF
}

# Simple loop to serve HTTP requests on /health
while true; do
    # Use socat for persistent HTTP server if available
    if command -v socat >/dev/null 2>&1; then
        socat TCP-LISTEN:${PORT},reuseaddr,fork EXEC:'bash -c "response=\"$(health_response)\"; echo -e \"\$response\""'
        exitcode=$?
        if [ $exitcode -eq 0 ]; then
            echo "Health server running with socat on port $PORT"
            break
        fi
    fi
    
    # Fallback using netcat in loop mode
    if command -v nc >/dev/null 2>&1; then
        echo "Serving health check with netcat on port $PORT"
        while true; do
            # Listen for connections and respond with health check
            {
                read -r request || true
                if echo "$request" | grep -q "GET /health"; then
                    health_response
                fi
            } | nc -l -p ${PORT}
            sleep 0.1
        done
    fi
    
    # Final fallback: simple socket listener using bash and curl
    if command -v curl >/dev/null 2>&1 && command -v nc >/dev/null 2>&1; then
        echo "Serving health check with netcat and curl fallback on port $PORT"
        while true; do
            nc -l -p ${PORT} -c 'echo -e "HTTP/1.1 200 OK\\r\\nContent-Type: application/json\\r\\nContent-Length: 15\\r\\n\\r\\n{\"status\":\"ok\"}"'
            sleep 0.5
        done
    fi
    
    # If nothing works, try busybox httpd
    if command -v busybox >/dev/null 2>&1 && busybox --list | grep -q "httpd"; then
        echo "Creating temporary busybox httpd server on port $PORT"
        mkdir -p /tmp/www
        echo '{"status":"ok"}' > /tmp/www/health
        busybox httpd -p $PORT -h /tmp/www
        break
    fi
    
    # If all fails, just keep the port open
    echo "Warning: No suitable HTTP server tool found. Keeping port $PORT open."
    echo 'while true; do sleep 3600; done' | bash
    break
done
