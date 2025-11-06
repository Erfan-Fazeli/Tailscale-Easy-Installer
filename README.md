# Tailscale Auto-Node Setup

One-click deploy - Auto-connect to your Tailscale network.

**✅ Auto-deploy | ✅ Smart fallback | ✅ All platforms**

## Quick Start

### 1. Get Auth Key
[Get key from Tailscale](https://login.tailscale.com/admin/settings/keys)

### 2. Configure `.env`
```bash
cp .env.example .env
# Edit .env and add your TAILSCALE_AUTH_KEY
```

### 3. Deploy & Watch Live Logs

#### **Codespaces**
1. Open repo in Codespaces
2. Auto-builds & runs → See live logs in terminal ✅

#### **Gitpod**
1. Open repo in Gitpod
2. Auto-builds & runs → See live logs in terminal ✅

#### **Railway**
1. Connect repo → Deploy
2. View logs: `railway logs` or dashboard

#### **Render / Koyeb**
1. Connect repo → Deploy
2. View logs in dashboard (real-time)

#### **Docker (Local)**
```bash
docker build -t ts-node .
docker run --rm -v $(pwd)/.env:/.env -p 8080:8080 ts-node
# Logs appear in terminal
```

## Features
- ✅ Works on all platforms
- ✅ Auto fallback to userspace mode
- ✅ Health check endpoint
- ✅ Small & optimized (~50 lines)

## License
MIT
