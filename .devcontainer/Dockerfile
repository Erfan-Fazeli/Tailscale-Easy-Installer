FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends curl ca-certificates iptables netcat-openbsd \
    && curl -fsSL https://tailscale.com/install.sh | sh - \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY .env /.env
COPY .devcontainer/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
