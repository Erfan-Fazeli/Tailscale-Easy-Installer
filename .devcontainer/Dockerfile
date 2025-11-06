# Dockerfile - Multi-Platform Tailscale Auto-Installer
# Supports: GitHub Codespaces, Render.com, Fly.io, Koyeb, Railway, etc.

FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies: curl, jq (JSON parsing), netcat (health checks), Tailscale
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        curl \
        jq \
        netcat-openbsd \
        ca-certificates \
        iptables \
    && curl -fsSL https://tailscale.com/install.sh | sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the universal startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose health check port
EXPOSE 8080

# Set working directory
WORKDIR /app

# Set the default command for all platforms
CMD ["/usr/local/bin/start.sh"]
