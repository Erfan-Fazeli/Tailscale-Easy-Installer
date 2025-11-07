<div align="center">

![Tailscale AutoNode Banner](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12,14,18,20,24&height=250&section=header&text=Tailscale%20AutoNode&fontSize=70&fontAlignY=35&desc=Deploy%20Your%20Private%20Network%20Infrastructure%20in%2060%20Seconds&descSize=25&descAlignY=55&animation=fadeIn)

[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://hub.docker.com/r/tailscale/tailscale)
[![Stars](https://img.shields.io/github/stars/Erfan-Fazeli/Tailscale_AutoNode?style=for-the-badge&color=yellow)](https://github.com/Erfan-Fazeli/Tailscale_AutoNode)

**Automated private network infrastructure with zero config - scalable and production-ready.**

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

<table>
<tr>
<td align="center" width="25%" style="padding: 20px; vertical-align: top;">

### 🐳 Docker

⏱️ `30 seconds`

<br>

**Best Performance**

Full Kernel Access

<br>

✅ Production Ready

<br><br>

*Self-hosted & Free*

</td>
<td align="center" width="25%" style="padding: 20px; vertical-align: top;">

### 🚂 Railway

⏱️ `~60 seconds`

<br>

**Auto-Scaling**

Global Edge Network

<br><br><br>

<a href="https://railway.app/new/template?template=https://github.com/Erfan-Fazeli/Tailscale_AutoNode">
  <img src="https://img.shields.io/badge/Deploy_Now-663399?style=for-the-badge&logo=railway&logoColor=white&labelColor=663399" alt="Deploy on Railway" height="40">
</a>

</td>
<td align="center" width="25%" style="padding: 20px; vertical-align: top;">

### 🎨 Render

⏱️ `~60 seconds`

<br>

**Zero Config**

Managed Infrastructure

<br><br><br>

<a href="https://render.com/deploy?repo=https://github.com/Erfan-Fazeli/Tailscale_AutoNode">
  <img src="https://img.shields.io/badge/Deploy_Now-46E3B7?style=for-the-badge&logo=render&logoColor=white&labelColor=46E3B7" alt="Deploy on Render" height="40">
</a>

</td>
<td align="center" width="25%" style="padding: 20px; vertical-align: top;">

### 🪁 Fly.io

⏱️ `~90 seconds`

<br>

**Multi-Region**

Edge Deployment

<br><br><br>

<a href="https://fly.io/launch">
  <img src="https://img.shields.io/badge/Deploy_Now-8B5CF6?style=for-the-badge&logo=fly&logoColor=white&labelColor=8B5CF6" alt="Deploy on Fly.io" height="40">
</a>

</td>
</tr>
</table>

</div>

---

## 📋 Platform-Specific Guides

### <img src="https://cdn.simpleicons.org/docker/2496ED" width="20" height="20" /> Docker

**Using Docker:**
```bash
docker run -d --name=tailscale \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -e TAILSCALE_AUTH_KEY=tskey-auth-your-key-here \
  -v /var/lib/tailscale:/var/lib/tailscale \
  ghcr.io/erfan-fazeli/tailscale-autonode:latest
```

**Using Docker Compose:**
```yaml
version: '3.8'
services:
  tailscale:
    image: ghcr.io/erfan-fazeli/tailscale-autonode:latest
    container_name: tailscale
    cap_add:
      - NET_ADMIN
      - NET_RAW
    environment:
      - TAILSCALE_AUTH_KEY=tskey-auth-your-key-here
    volumes:
      - ./tailscale:/var/lib/tailscale
    restart: unless-stopped
```

Then run:
```bash
docker-compose up -d
```

---

<details>
<summary><img src="https://cdn.simpleicons.org/railway/0B0D0E" width="16" height="16" /> <b>Railway</b></summary>

<br>

1. Click the Railway deploy button above
2. Enter your `TAILSCALE_AUTH_KEY` when prompted
3. Deploy - done! Your node appears in Tailscale admin in ~60 seconds

</details>

<details>
<summary><img src="https://cdn.simpleicons.org/render/46E3B7" width="16" height="16" /> <b>Render</b></summary>

<br>

1. Click the Render deploy button
2. Fork this repo (Render will prompt you)
3. Set `TAILSCALE_AUTH_KEY` in environment variables
4. Deploy and wait ~60 seconds

</details>

<details>
<summary><img src="https://cdn.simpleicons.org/heroku/430098" width="16" height="16" /> <b>Heroku</b></summary>

<br>

The deploy button handles everything - just add your auth key when prompted!

</details>

<details>
<summary><img src="https://cdn.simpleicons.org/fly/8B5CF6" width="16" height="16" /> <b>Fly.io</b></summary>

<br>

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
1. **Deploy** → Your network node registers and joins the mesh
2. **Mesh Formation** → Nodes discover each other and build the network topology
3. **Smart Routing** → Traffic intelligently routes through the best available path
4. **NAT Bypass** → DERP relays ensure connectivity across any network environment

### Network Modes
- **Kernel Mode** (Docker): Best performance, full NAT support
- **Userspace Mode** (Cloud): Works everywhere, slightly slower

---

## 💡 Use Cases

- **Enterprise Networking**: Build secure, scalable private networks across multiple regions
- **Infrastructure as Code**: Deploy network nodes as part of your infrastructure automation
- **Multi-Cloud Connectivity**: Connect resources across AWS, GCP, Azure seamlessly
- **Edge Computing**: Create distributed network infrastructure with automatic failover
- **Development & Staging**: Isolated network environments for different deployment stages

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
