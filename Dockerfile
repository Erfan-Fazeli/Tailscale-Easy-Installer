FROM ubuntu:24.04

# Install Tailscale and minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        iptables \
        iproute2 \
        netcat-openbsd && \
    curl -fsSL https://tailscale.com/install.sh | sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create TUN device (fails silently in restricted environments)
RUN mkdir -p /dev/net && \
    (mknod /dev/net/tun c 10 200 2>/dev/null || true) && \
    chmod 600 /dev/net/tun 2>/dev/null || true

COPY start.sh entrypoint.sh /
RUN chmod +x /start.sh /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]
