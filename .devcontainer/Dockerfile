FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install necessary packages and Tailscale
RUN set -ex; \
    apt-get update; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get install -y --no-install-recommends curl ca-certificates iptables netcat-openbsd; \
    mkdir -p /dev/net; \
    mknod /dev/net/tun c 10 200; \
    modprobe tun || true; \
    curl -fsSL https://tailscale.com/install.sh | sh -; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

COPY .env /.env
COPY .devcontainer/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
