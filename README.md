<div align="center">

# 🌐 Tailscale AutoNode

### _Your Personal VPN Exit Node, Deployed in 60 Seconds_

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)
[![Deploy to Fly.io](https://img.shields.io/badge/deploy-fly.io-blueviolet?style=for-the-badge&logo=fly.io)](https://fly.io/docs/getting-started/)
[![Docker](https://img.shields.io/badge/docker-ready-blue?style=for-the-badge&logo=docker)](https://www.docker.com/)

**Zero config • Auto-fallback • Production ready**

---

</div>

## 🎯 What is this?

Turn any cloud server into your **private VPN exit node** with Tailscale. Browse the internet through your own server, bypass geo-restrictions, and secure your traffic—all with automatic setup.

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│  Your PC    │────────▶│  Tailscale   │────────▶│  Exit Node   │────────▶ Internet
│  or Phone   │         │   Network    │         │ (This Thing) │
└─────────────┘         └──────────────┘         └──────────────┘
```

### ✨ Features

- 🚀 **One-Click Deploy** - Works on Fly.io, Render, Railway, DigitalOcean, or any Docker host
- 🧠 **Smart Fallback** - Automatically adapts to privileged or restricted environments
- 🌍 **Auto Location** - Detects and labels your server's country automatically
- 🔒 **Secure** - Leverages Tailscale's WireGuard-based mesh VPN
- 📦 **Minimal** - Tiny Docker image, low resource usage (~50MB RAM)
- ⚡ **Fast Setup** - From zero to VPN in under 60 seconds

---

## 🚀 Quick Start

### Prerequisites

1. **Tailscale Account** (free): [Sign up here](https://login.tailscale.com/start)
2. **Auth Key**: Get one from [Tailscale Keys](https://login.tailscale.com/admin/settings/keys)
   - ✅ Check "Reusable"
   - ✅ Check "Ephemeral" (optional, auto-cleanup)

### Method 1: Deploy to Fly.io (Recommended)

```bash
# Install flyctl if you haven't
curl -L https://fly.io/install.sh | sh

# Clone and deploy
git clone https://github.com/yourusername/tailscale-autonode
cd tailscale-autonode

# Set your auth key as secret
fly secrets set TAILSCALE_AUTH_KEY=tskey-auth-xxxxx

# Deploy!
fly launch --yes
fly deploy
```

**That's it!** ✨ Your exit node is live.

---

### Method 2: Deploy to Render

1. Click: [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)
2. Add your `TAILSCALE_AUTH_KEY` as environment variable
3. Click "Create Web Service"
4. Done! 🎉

---

### Method 3: Docker Compose (Self-Hosted)

```bash
# Clone the repo
git clone https://github.com/yourusername/tailscale-autonode
cd tailscale-autonode

# Create .env file from example
cp .env.example .env

# Edit .env and add your Tailscale auth key
nano .env

# Deploy
docker-compose up -d

# Check logs
docker-compose logs -f
```

---

### Method 4: Railway / Koyeb / Other Platforms

1. Fork this repository
2. Connect to your platform of choice
3. Add environment variable: `TAILSCALE_AUTH_KEY=your-key`
4. Deploy from the dashboard
5. Profit! 🚀

---

## ⚙️ Configuration

Create a `.env` file (or set environment variables):

```bash
# Required
TAILSCALE_AUTH_KEY=tskey-auth-xxxxxxxxxxxxx

# Optional - Customize hostname prefix
HOSTNAME_PREFIX=MyVPN

# Optional - Override country detection
COUNTRY_CODE_OVERRIDE=US

# Optional - Change health check port
HTTP_PORT=8080
```

### Hostname Generation

The container automatically generates hostnames like:
- `US-a3f9` (auto-detected country)
- `MyVPN-US-a3f9` (with prefix)
- `FR-k2h8` (with override)

---

## 🎮 Usage

### 1. Approve the Exit Node

After deployment, go to [Tailscale Machines](https://login.tailscale.com/admin/machines) and:

1. Find your new node (e.g., `US-a3f9`)
2. Click the three dots `⋯`
3. Click **"Edit route settings..."**
4. Enable **"Use as exit node"**
5. Click **Save**

### 2. Connect from Your Device

#### On macOS/Windows/Linux:
```bash
# Use your exit node
tailscale up --exit-node=US-a3f9

# Or from the GUI:
# Menu → Exit Node → Select your node
```

#### On iPhone/Android:
1. Open Tailscale app
2. Tap `⋯` menu
3. Tap **Exit Node**
4. Select your node
5. Done! 🎉

### 3. Verify It's Working

```bash
# Check your current IP
curl ifconfig.me

# Should show your exit node's IP!
```

---

## 🏗️ How It Works

### Intelligent Deployment Strategy

```mermaid
graph TD
    A[Start Container] --> B{Try Kernel Mode}
    B -->|Success| C[Full Exit Node ✅]
    B -->|Fail| D{Try Userspace Mode}
    D -->|Success| E[Limited Exit Node ⚠️]
    D -->|Fail| F[Regular Client 📱]

    C --> G[Enable IP Forwarding]
    G --> H[Advertise as Exit Node]

    E --> I[No IP Forwarding]
    I --> J[Try Exit Node Mode]
    J -->|Fail| K[Connect as Client]
```

### Platform Compatibility

| Platform | Mode | Exit Node | Performance |
|----------|------|-----------|-------------|
| **Fly.io** | Kernel | ✅ Full | ⚡⚡⚡ Excellent |
| **VPS (DO/Linode/Vultr)** | Kernel | ✅ Full | ⚡⚡⚡ Excellent |
| **Docker (privileged)** | Kernel | ✅ Full | ⚡⚡⚡ Excellent |
| **Railway** | Userspace | ⚠️ Limited | ⚡⚡ Good |
| **Render** | Userspace | ⚠️ Limited | ⚡⚡ Good |
| **Codespaces** | Userspace | ⚠️ Limited | ⚡⚡ Good |

---

## 🔧 Advanced Usage

### Run with Privileged Access

For **maximum performance** on platforms that support it:

```bash
# Docker
docker run -d \
  --name tailscale-exit \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --device=/dev/net/tun \
  -p 8080:8080 \
  -e TAILSCALE_AUTH_KEY=tskey-auth-xxxxx \
  your-image-name

# Docker Compose (already configured)
docker-compose up -d
```

### Health Check

The container exposes a health endpoint on port 8080:

```bash
curl http://localhost:8080
# {"status":"ok"}
```

### Custom Deployment

```yaml
# docker-compose.yml
services:
  tailscale:
    build: .
    environment:
      - TAILSCALE_AUTH_KEY=${TAILSCALE_AUTH_KEY}
      - HOSTNAME_PREFIX=MyNetwork
      - COUNTRY_CODE_OVERRIDE=NL
    ports:
      - "8080:8080"
    volumes:
      - tailscale-state:/var/lib/tailscale
    restart: unless-stopped
```

---

## 🐛 Troubleshooting

### Container starts but not showing in Tailscale?

**Check logs:**
```bash
docker logs <container-name>
```

**Common issues:**
- Invalid auth key → Generate new one
- Key expired → Create non-ephemeral key
- Network blocked → Check firewall (UDP 41641)

### Exit node not appearing in clients?

1. Go to [Tailscale Machines](https://login.tailscale.com/admin/machines)
2. Find your node
3. Edit route settings
4. Enable "Use as exit node"

### Performance issues?

**If on userspace mode:**
- Deploy to platform with privileged support (Fly.io, VPS)
- Userspace networking has ~20-30% overhead

**General:**
- Choose region close to you
- Check server specs (min: 256MB RAM, 1 CPU)

### Connection keeps dropping?

```bash
# Check if container is restarting
docker ps -a

# Check Tailscale status
docker exec <container-name> tailscale status

# Recreate with non-ephemeral key
```

---

## 📊 Resource Usage

Typical usage on a `256MB RAM / 1 vCPU` machine:

```
Memory:  ~40-60 MB
CPU:     <5% idle, ~10-20% under load
Disk:    ~150 MB (Docker image)
Network: Depends on your usage
```

**Cost estimates:**
- Fly.io Free Tier: **$0/month** (within limits)
- Render Free Tier: **$0/month** (750 hours)
- DigitalOcean: **$6/month** (basic droplet)

---

## 🔒 Security Notes

- ✅ All traffic encrypted with WireGuard
- ✅ Only accessible via your Tailscale network
- ✅ No public endpoints exposed (except health check)
- ⚠️ **Never commit `.env` file** (already in `.gitignore`)
- ⚠️ **Rotate auth keys** periodically
- ⚠️ **Use ephemeral keys** for auto-cleanup

---

## 🤝 Contributing

Found a bug? Have an idea? PRs welcome!

1. Fork this repo
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

---

## 📝 License

MIT License - use it, modify it, have fun!

---

## 🌟 Support

If this project helped you, consider:
- ⭐ Starring the repo
- 🐦 Sharing on Twitter
- ☕ [Buy me a coffee](https://example.com) (optional)

---

<div align="center">

**Made with ❤️ and lots of ☕**

[Report Bug](https://github.com/yourusername/tailscale-autonode/issues) ·
[Request Feature](https://github.com/yourusername/tailscale-autonode/issues) ·
[Tailscale Docs](https://tailscale.com/kb/)

</div>
