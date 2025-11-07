FROM ubuntu:24.04

# Install Tailscale and minimal dependencies (including libcap for capability checks)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        iptables \
        ip6tables \
        iproute2 \
        netcat-openbsd \
        kmod \
        libcap2-bin && \
    curl -fsSL https://tailscale.com/install.sh | sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create TUN device (fails silently in restricted environments)
RUN mkdir -p /dev/net && \
    (mknod /dev/net/tun c 10 200 2>/dev/null || true) && \
    chmod 600 /dev/net/tun 2>/dev/null || true

# Create state directories for Tailscale
RUN mkdir -p /var/lib/tailscale /var/run/tailscale /tmp && \
    chmod 755 /var/lib/tailscale /var/run/tailscale

# Copy scripts
COPY start.sh entrypoint.sh /
RUN chmod +x /start.sh /entrypoint.sh

# Expose health check port
EXPOSE 8080

# Set environment for better exit node compatibility
ENV TAILSCALE_USE_WIP_CODE=1 \
    TAILSCALE_DEBUG_FIREWALL_MODE=auto

CMD ["/entrypoint.sh"]
