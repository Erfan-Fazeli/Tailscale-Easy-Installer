<div align="center">

![Tailscale AutoNode Banner](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12,14,18,20,24&height=250&section=header&text=Tailscale%20AutoNode&fontSize=70&fontAlignY=35&desc=Deploy%20Your%20VPN%20Exit%20Node%20in%2060%20Seconds&descSize=25&descAlignY=55&animation=fadeIn)

[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://hub.docker.com/r/tailscale/tailscale)
[![Stars](https://img.shields.io/github/stars/Erfan-Fazeli/Tailscale_AutoNode?style=for-the-badge&color=yellow)](https://github.com/Erfan-Fazeli/Tailscale_AutoNode)

**Automated Tailscale exit nodes - zero config, just deploy.**

</div>

---

## ✨ Features

- **🎯 Zero-Config**: Deploy in 60 seconds, no complex setup
- **🔒 Secure**: End-to-end encryption with zero-trust architecture
- **🌐 Mesh Networking**: Your devices automatically discover the best routes through multiple nodes. If one path fails, traffic seamlessly reroutes through alternative nodes in the mesh
- **🔓 NAT Bypass**: Direct peer-to-peer connections even behind strict firewalls and NAT. No port forwarding needed - DERP relay ensures you're always connected
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

### <img src="https://www.docker.com/wp-content/uploads/2022/03/Moby-logo.png" width="20" height="20"> Docker (Recommended)
```bash
docker run -d --name=tailscale \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -e TAILSCALE_AUTH_KEY=tskey-auth-your-key-here \
  -v /var/lib/tailscale:/var/lib/tailscale \
  ghcr.io/erfan-fazeli/tailscale-autonode:latest
```

<details>
<summary><img src="https://railway.app/brand/logo-light.png" width="20" height="20"> Railway</summary>

1. Click the Railway deploy button above
2. Enter your `TAILSCALE_AUTH_KEY` when prompted
3. Deploy - done! Your node appears in Tailscale admin in ~60 seconds

</details>

<details>
<summary><img src="https://render.com/images/logo-symbol.svg" width="20" height="20"> Render</summary>

1. Click the Render deploy button
2. Fork this repo (Render will prompt you)
3. Set `TAILSCALE_AUTH_KEY` in environment variables
4. Deploy and wait ~60 seconds

</details>

<details>
<summary><img src="https://www.vectorlogo.zone/logos/heroku/heroku-icon.svg" width="20" height="20"> Heroku</summary>

The deploy button handles everything - just add your auth key when prompted!

</details>

<details>
<summary><img src="https://fly.io/public/images/brand/logo.svg" width="20" height="20"> Fly.io</summary>

```bash
git clone https://github.com/Erfan-Fazeli/Tailscale_AutoNode
cd Tailscale_AutoNode
fly launch --no-deploy
fly secrets set TAILSCALE_AUTH_KEY=tskey-auth-your-key-here
fly deploy
```

</details>

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

<div align="center">

```mermaid
graph TB
    subgraph "🌐 Your Mesh Network"
        A[💻 Laptop] -.->|Direct P2P| B[📱 Phone]
        A -.->|Mesh Route| C[🖥️ Desktop]
        B -.->|Mesh Route| C

        A -->|Route via Exit Node| D[☁️ Exit Node<br/>Your Deploy]
        B -->|Route via Exit Node| D
        C -->|Route via Exit Node| D
    end

    D -->|Encrypted Tunnel| E[🌍 Internet]

    subgraph "🔒 Tailscale Control"
        F[🎛️ Control Plane<br/>Coordination & Auth]
    end

    A -.->|Register & Discover| F
    B -.->|Register & Discover| F
    C -.->|Register & Discover| F
    D -.->|Register & Discover| F

    style D fill:#4CAF50,stroke:#333,stroke-width:2px,color:#fff
    style E fill:#2196F3,stroke:#333,stroke-width:2px,color:#fff
    style F fill:#FF9800,stroke:#333,stroke-width:2px,color:#fff
```

</div>

**How it works:**
1. **Deploy** → Your exit node registers with Tailscale
2. **Mesh Formation** → All your devices discover each other automatically
3. **Smart Routing** → Traffic finds the best path (direct P2P or via exit node)
4. **NAT Bypass** → DERP relays ensure connectivity even behind firewalls

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
