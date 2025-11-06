# Tailscale Exit Node - One-Click Deploy

Zero-config Tailscale exit node deployment. Just click deploy!

## One-Click Deploy

### GitHub Codespaces
Click: Code → Codespaces → Create codespace ✅

### Render
Click: [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

### Fly.io
```bash
fly launch --yes
fly deploy
```

### Docker
```bash
docker-compose up -d
```

## First Time Setup

1. Get Tailscale auth key: [Keys](https://login.tailscale.com/admin/settings/keys)
2. Edit `.env` file and add your key
3. Deploy (see above)
4. Approve exit node: [Machines](https://login.tailscale.com/admin/machines)

## Configuration

Edit `.env` file:
```bash
TAILSCALE_AUTH_KEY=your-key-here
HOSTNAME_PREFIX=               # Optional
COUNTRY_CODE_OVERRIDE=         # Optional
HTTP_PORT=8080                 # Optional
```

That's it! No environment variables, no manual setup required.
