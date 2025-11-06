# Multi-Platform Tailscale Exit Node
# Supports: Codespaces, Render, Fly.io, Railway, Koyeb, Docker
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install Tailscale and dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        curl ca-certificates iptables netcat-openbsd \
    && curl -fsSL https://tailscale.com/install.sh | sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080
WORKDIR /app
CMD ["/usr/local/bin/start.sh"]
