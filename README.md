<div align="center">

```
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║           🚀  T A I L S C A L E   A U T O N O D E  🚀           ║
║                                                                   ║
║        Deploy your own VPN exit node in 60 seconds, anywhere     ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://hub.docker.com/r/tailscale/tailscale)
[![Stars](https://img.shields.io/github/stars/Erfan-Fazeli/Tailscale_AutoNode?style=for-the-badge&color=yellow)](https://github.com/Erfan-Fazeli/Tailscale_AutoNode)

**One-click automated Tailscale exit nodes. No config files, no complex setup - just click deploy and paste your auth key.**

</div>

---

## ✨ Features

- **🎯 Zero-Config**: Deploy in 60 seconds, no complex setup
- **🔒 Secure**: End-to-end encryption with zero-trust architecture
- **🌐 Smart Routing**: Automatic mesh networking with self-healing paths
- **🌍 Global**: Deploy exit nodes anywhere in the world
- **📊 Monitoring**: Built-in health checks and status dashboard

---

## 🚀 Quick Deploy

### Step 1: Get Your Auth Key
Get your Tailscale auth key from [here](https://login.tailscale.com/admin/settings/keys). Make sure it's **reusable**.

### Step 2: Pick a Platform & Deploy

Click a button below to deploy. You'll be prompted for your `TAILSCALE_AUTH_KEY` - just paste it and you're done!

<div align="center">

| Platform | Time | Exit Node | Cost |
|----------|------|-----------|------|
| **Docker** | 30s | ✅ | Free |
| **Railway** | 60s | ⚠️ | $5/mo |
| **Render** | 60s | ⚠️ | $7/mo |
| **Fly.io** | 90s | ⚠️ | $5/mo |
| **Heroku** | 90s | ❌ | $5/mo |

</div>

<div align="center">
  <a href="https://railway.app/new/template?template=https://github.com/Erfan-Fazeli/Tailscale_AutoNode">
    <img src="https://img.shields.io/badge/Deploy_on-Railway-663399?style=for-the-badge&logo=railway&logoColor=white" alt="Deploy on Railway">
  </a>
  <a href="https://render.com/deploy?repo=https://github.com/Erfan-Fazeli/Tailscale_AutoNode">
    <img src="https://img.shields.io/badge/Deploy_to-Render-46E3B7?style=for-the-badge&logo=render&logoColor=white" alt="Deploy on Render">
  </a>
  <a href="https://heroku.com/deploy?template=https://github.com/Erfan-Fazeli/Tailscale_AutoNode">
    <img src="https://img.shields.io/badge/Deploy_to-Heroku-430098?style=for-the-badge&logo=heroku&logoColor=white" alt="Deploy on Heroku">
  </a>
  <a href="https://fly.io/launch">
    <img src="https://img.shields.io/badge/Deploy_on-Fly.io-8B5CF6?style=for-the-badge&logo=fly.io&logoColor=white" alt="Deploy on Fly.io">
  </a>
</div>

---

## 📋 Platform-Specific Guides

### 🐳 Docker (Recommended)
```bash
docker run -d --name=tailscale \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -e TAILSCALE_AUTH_KEY=tskey-auth-your-key-here \
  -v /var/lib/tailscale:/var/lib/tailscale \
  ghcr.io/erfan-fazeli/tailscale-autonode:latest
```

### 🚂 Railway
1. Click the Railway deploy button above
2. Enter your `TAILSCALE_AUTH_KEY` when prompted
3. Deploy - done! Your node appears in Tailscale admin in ~60 seconds

### 🎨 Render
1. Click the Render deploy button
2. Fork this repo (Render will prompt you)
3. Set `TAILSCALE_AUTH_KEY` in environment variables
4. Deploy and wait ~60 seconds

### 🪁 Fly.io
```bash
git clone https://github.com/Erfan-Fazeli/Tailscale_AutoNode
cd Tailscale_AutoNode
fly launch --no-deploy
fly secrets set TAILSCALE_AUTH_KEY=tskey-auth-your-key-here
fly deploy
```

### 🟣 Heroku
The deploy button handles everything - just add your auth key when prompted!

### ✨ Auto-Configuration
Everything below happens automatically:
- Exit node advertising (approve in admin panel)
- Smart hostname generation
- Country/region detection
- Health monitoring on port 8080

---

## ⚙️ Configuration

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `TAILSCALE_AUTH_KEY` | ✅ | - | Your auth key from Tailscale |
| `HOSTNAME_PREFIX` | No | `AutoNode-` | Custom hostname prefix |
| `HTTP_PORT` | No | `8080` | Health check port |

### Enable Exit Node
After deploying, enable your node as an exit node:
1. Go to [Tailscale Admin](https://login.tailscale.com/admin/machines)
2. Find your node → **Edit route settings**
3. Enable **"Use as exit node"** → Save

---

## 📊 Monitoring

Check your node health at `http://your-node:8080/health`

```json
{
  "status": "connected",
  "hostname": "AutoNode-Railway-US",
  "tailscale_ip": "100.64.0.5",
  "exit_node_enabled": true
}
```

---

## 🏗️ How It Works

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Internet   │────▶│  Exit Node   │────▶│   Tailscale  │
│              │     │ (Your Deploy)│     │   Network    │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │ Your Devices │
                    │  (Mesh VPN)  │
                    └──────────────┘
```

**What happens:**
1. Your node connects to Tailscale control plane
2. Auto-advertises as an exit node
3. You approve it in the admin panel
4. All your devices can route through this node

### Network Modes
- **Kernel Mode** (Docker): Best performance, full NAT support
- **Userspace Mode** (Cloud): Works everywhere, slightly slower

---

## 💡 Use Cases

- **Remote Work**: Secure access to your home/office network from anywhere
- **Privacy**: Route traffic through your own server instead of commercial VPNs
- **Multi-Region**: Deploy exit nodes globally for lower latency
- **Development**: Secure access to staging/dev environments

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Node offline | Check auth key is valid and reusable |
| Exit node not working | Enable it in [Tailscale Admin](https://login.tailscale.com/admin/machines) |
| Can't connect | Ensure `TAILSCALE_AUTH_KEY` is set correctly |

**Still stuck?** Open an issue on [GitHub](https://github.com/Erfan-Fazeli/Tailscale_AutoNode/issues).

---

## 📄 License

MIT License - free to use, modify, and distribute.

---

<div align="center">

### ⭐ Like this project? Give it a star!

[![GitHub stars](https://img.shields.io/github/stars/Erfan-Fazeli/Tailscale_AutoNode?style=social)](https://github.com/Erfan-Fazeli/Tailscale_AutoNode)

**Built with ❤️ for the Tailscale community**

</div>
