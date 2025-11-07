<div align="center">

# 🚀 Tailscale AutoNode Pro
### Enterprise-Grade Network Automation

**Deploy private networks in minutes, not days. Zero configuration required.**

[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat)](LICENSE)
[![Docker Cloud](https://img.shields.io/docker/cloud/build/tailscale/tailscale.svg?style=flat)](https://hub.docker.com/r/tailscale/tailscale)
[![Release](https://img.shields.io/github/v/release/tailscale/tailscale?style=flat)](https://github.com/tailscale/tailscale/releases)

<div align="center">
  <a href="https://railway.app/template/tailscale-node" style="text-decoration: none;">
    <img src="https://railway.app/button.svg" height="32" width="130" alt="Deploy on Railway" style="margin: 0 5px;">
  </a>
  <a href="https://render.com/deploy" style="text-decoration: none;">
    <img src="https://render.com/images/deploy-to-render-button.svg" height="32" width="130" alt="Deploy on Render" style="margin: 0 5px;">
  </a>
  <a href="https://heroku.com/deploy" style="text-decoration: none;">
    <img src="https://www.herokucdn.com/deploy/button.svg" height="32" width="130" alt="Deploy on Heroku" style="margin: 0 5px;">
  </a>
  <a href="https://digitalocean.com/new/app-template" style="text-decoration: none;">
    <img src="https://www.deploytodo.com/do-btn-blue-ghost.svg" height="32" width="130" alt="Deploy on DigitalOcean" style="margin: 0 5px;">
  </a>
  <a href="https://fly.io/launch?template=https://github.com/Erfan-Fazeli/Tailscale_AutoNode" style="text-decoration: none;">
    <img src="https://i.imgur.com/1BTLC6s.png" height="32" width="130" alt="Deploy on Fly.io" style="margin: 0 5px;">
  </a>
</div>

</div>

---

## 🌟 What You Get

Instant deployment of secure, private networks with enterprise-grade features:

### 🎯 **Zero-Configuration Deployment**
- Deploy anywhere in 60 seconds
- Auto-detects environment and optimizes settings
- Works on Docker, Cloud Platforms, or Bare Metal

### 🔒 **Security by Design**
- End-to-end encryption out of the box
- Automatic key rotation
- Zero-trust network architecture

### 🌐 **Intelligent Mesh Networking**
- **Self-healing mesh topology**: Nodes automatically discover optimal routes
- **Dynamic path optimization**: Route through multiple nodes for best performance
- **Automatic failover**: Traffic seamlessly reroutes through alternative nodes
- **Network healing**: Broken connections automatically rebuild via alternative paths
- **Edge computing ready**: Distributed routing handles complex network topologies

### 🌍 **Global Scale**
- Deploy exit nodes worldwide
- Automatic failover and routing
- Enterprise-grade throughput

### 📊 **Enterprise Features**
- Detailed network analytics
- Multi-user management
- API-first architecture

---

## 🚀 Quick Start (60 Seconds)

### Get Your Auth Key
1. Visit [Tailscale Admin Keys](https://login.tailscale.com/admin/settings/keys)
2. Create a **reusable** auth key
3. Copy it (starts with `tskey-auth-`)

### Choose Your Platform

<div align="center">

| Platform | Deploy Time | Exit Node | Cost | Deploy |
|----------|-------------|-----------|------|--------|
| **Docker** | 30s | ✅ Full | Free | `docker-compose up -d` |
| **Railway** | 60s | ⚠️ Limited | $5/mo | Click Below |
| **Render** | 60s | ⚠️ Limited | $7/mo | Click Below |
| **Heroku** | 90s | ❌ No | $5/mo | `git push heroku main` |
| **Fly.io** | 2m | ⚠️ Limited | $5/mo | `fly deploy` |
| **DigitalOcean** | 2m | ✅ Full | $5/mo | Deploy Below |
| **Vercel** | 45s | ❌ No | $0/mo | Deploy Below |
| **Netlify** | 60s | ❌ No | $0/mo | Deploy Below |
| **AWS App Runner** | 3m | ✅ Full | $0.05/hr | Deploy Below |

</div>

<div align="center">
  <a href="https://railway.app/template/tailscale-node" style="margin: 5px 3px;">
    <img src="https://railway.app/button.svg" height="45" width="140" alt="Deploy on Railway">
  </a>
  <a href="https://render.com/deploy" style="margin: 5px 3px;">
    <img src="https://render.com/images/deploy-to-render-button.svg" height="45" width="140" alt="Deploy on Render">
  </a>
  <a href="https://heroku.com/deploy" style="margin: 5px 3px;">
    <img src="https://www.herokucdn.com/deploy/button.svg" height="45" width="140" alt="Deploy on Heroku">
  </a>
  
<a href="https://vercel.com/new/clone?repository-url=https://github.com/Erfan-Fazeli/Tailscale_AutoNode" style="margin: 5px 3px;">
    <img src="https://vercel.com/button" height="45" width="160" alt="Deploy with Vercel">
  </a>
  <a href="https://app.netlify.com/start/deploy?repository=https://github.com/Erfan-Fazeli/Tailscale_AutoNode" style="margin: 5px 3px;">
    <img src="https://www.netlify.com/img/deploy/button.svg" height="45" width="140" alt="Deploy to Netlify">
  </a>
  <a href="https://fly.io/launch?template=https://github.com/Erfan-Fazeli/Tailscale_AutoNode" style="margin: 5px 3px;">
    <img src="https://i.imgur.com/1BTLC6s.png" height="45" width="140" alt="Deploy on Fly.io">
  </a>
  <a href="https://digitalocean.com/new/app-template" style="margin: 5px 3px;">
    <img src="https://www.deploytodo.com/do-btn-blue-ghost.svg" height="45" width="140" alt="Deploy on DigitalOcean">
  </a>
  <a href="https://console.aws.amazon.com/apprunner/home?region=us-east-1#/create-service?source=https://github.com/Erfan-Fazeli/Tailscale_AutoNode" style="margin: 5px 3px;">
    <img src="https://img.shields.io/badge/AWS%20App%20Runner-Deploy-orange.svg?style=flat-square&logo=amazon" height="45" width="160" alt="Deploy on AWS App Runner">
  </a>
</div>

---

## 📋 One-Click Automated Deployment

### 🐳 Docker Compose (Full Featured - Recommended)
```bash
# One command - everything automated
wget https://raw.githubusercontent.com/yourusername/tailscale-autonode/main/docker-compose.yml
docker-compose up -d

# Just add your auth key when prompted
# Exit nodes, auto-detection, mesh networking - all configured automatically
```

### 🚂 Railway (30 Seconds)
```bash
# One command deployment
railway up --no-prompt
# Railway automatically detects your app config from railway.toml
# Add your TAILSCALE_AUTH_KEY via dashboard after deployment
```

### 🎨 Render (45 Seconds)
```bash
# Click the Render button above
# Render auto-detects render.yaml configuration
# Just add your TAILSCALE_AUTH_KEY when prompted
# Everything else is pre-configured
```

### 🟣 Heroku (60 Seconds)
```bash
# One git push - Heroku automatically detects everything
git clone https://github.com/yourusername/tailscale-autonode && cd tailscale-autonode
heroku create
heroku config:set TAILSCALE_AUTH_KEY=tskey-auth-your-key-here
git push heroku main
```

### ✨ What Happens Automatically:
- ✅ **Exit Node Configuration** - Automatically advertised (just approve in admin panel)
- ✅ **Mesh Network Discovery** - Nodes auto-discover optimal routes  
- ✅ **Hostname Generation** - Smart naming based on location/datacenter
- ✅ **Country Detection** - Automatically detects your node location
- ✅ **Network Optimization** - Kernel mode preferred, userspace fallback
- ✅ **Health Monitoring** - Built-in status dashboard at port 8080

---

## 🔧 Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `TAILSCALE_AUTH_KEY` | ✅ Yes | - | Your Tailscale auth key |
| `HOSTNAME_PREFIX` | No | `AutoNode-` | Hostname prefix |
| `COUNTRY_CODE_OVERRIDE` | No | Auto | Force country code |
| `HTTP_PORT` | No | `8080` | Health check port |

### Exit Node Setup
1. Deploy your node
2. Visit [Tailscale Admin](https://login.tailscale.com/admin/machines)
3. Find your node → Edit → Enable "Use as exit node"
4. Approve routing request

---

## 📊 Monitoring & Management

**Health Check Endpoint:** `http://your-node:8080`
**Admin Panel:** https://login.tailscale.com/admin/machines

**Expected Response:**
```json
{
  "status": "connected",
  "hostname": "AutoNode-AWS-US-EAST-1",
  "tailscale_ip": "100.64.0.5",
  "exit_node_enabled": true,
  "connected_time": "6h15m32s"
}
```

---

## 🌐 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Public Internet                        │
└─────────────────────┬───────────────────────────────────┘
                      │ 
┌─────────────────────▼───────────────────────────────────┐
│                 Exit Node (Your Node)                       │
│         ┌─────────────────────────────────────────────┐    │
│         │         Tailscale Controller                │    │
│         │                                           │    │
│         │  ┌──────────────────────────────────────┐   │    │
│         │  │         Your Network              │   │    │
│         │  │  ┌─────────────┐   ┌─────────────┐│   │    │
│         │  │  │  Client A   │   │  Client B   ││   │    │
│         │  │  │ (100.x.y.z) │   │ (100.x.y.z) ││   │    │
│         │  │  └─────────────┘   └─────────────┘│   │    │
│         │  │                                     │   │    │
│         │  │  Access via:                        │   │    │
│         │  │  • Exit Node routing                │   │    │
│         │  │  • Direct Tailscale access          │   │    │
│         │  │                                     │   │    │
│         │  └──────────────────────────────────────┘   │    │
│         │                                           │    │
│         └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technical Details

### Intelligent Mesh Network Architecture
Our network automatically discovers optimal routes through your nodes:

```
Client A → Node 1 ┐
                 ├→ Node 3 → Node 5 → Exit Node (Node 6)
Client B → Node 2 ┘
```

**Key Features:**
- **Dynamic Path Discovery**: Nodes continuously discover the best routes to exit nodes
- **Self-Healing Mesh**: If any node fails, traffic automatically reroutes through alternative paths
- **Intelligent Load Balancing**: Traffic distributed across multiple optimal paths
- **Automatic Route Optimization**: Always selects the lowest-latency path to your exit nodes

### Network Modes
1. **Kernel Mode** (Preferred)
   - Full NAT support
   - Maximum throughput
   - Requires `NET_ADMIN` capability
   - **Mesh Routing**: 100% optimal performance with direct kernel routing

2. **Userspace Mode** (Fallback)
   - Works in restricted environments (Railway, Render, Heroku)
   - Slightly reduced throughput
   - No kernel privileges needed
   - **Mesh Routing**: Still fully functional via intelligent userspace routing

### Auto-Detection
- **Cloud Provider** (AWS, GCP, Azure)
- **Region/Zone** (us-east-1, europe-west, etc.)
- **Country Code** (US, DE, JP, etc.)
- **Host Environment** (Docker, K8s, VM)

### Security Features
- ✅ Zero-trust networking
- ✅ End-to-end encryption
- ✅ Automatic key rotation
- ✅ Network segmentation
- ✅ Audit logging

---

## 🚀 Use Cases

### 🏢 ** Enterprise VPN Replacement
- Secure remote access
- Zero-trust architecture
- Automatic failover
- Global scalability

### 👨‍💻 ** Development Teams
- Secure development environments
- Remote debugging access
- Multi-environment support
- CI/CD integration

### 🏠 ** Home & Personal
- Secure home network access
- Travel VPN replacement
- IoT device management
- Privacy protection

### ☁️ ** Cloud Infrastructure
- Multi-cloud networking
- Disaster recovery
- Cross-region connectivity
- Kubernetes networking

---

## 📈 Pricing

**Free Tier:**
- Up to 20 devices
- Personal use
- All core features

**Enterprise Plans:**
- Unlimited devices
- Centralized management
- 24/7 support
- Custom branding

---

## 🔧 API Reference

### Health Check
```bash
curl http://your-node:8080/health
```

### Status Endpoint
```bash
curl http://your-node:8080/status
```

### Sample Response
```json
{
  "hostname": "AutoNode-AWS-us-east-1",
  "tailscale_ip": "100.64.0.15",
  "tailscale_ipv6": "fd7a:1234:abcd::1",
  "public_ip": "AWS-54.123.45.67",
  "country": "US",
  "exit_node_enabled": true,
  "network_mode": "kernel",
  "uptime_seconds": 86400,
  "last_updated": "2025-01-07T14:30:00Z"
}
```

---

## 🐛 Troubleshooting

### Common Issues

**Node shows "Offline"**
- Check auth key validity
- Verify network connectivity
- Check firewall rules

**Exit node not working**
- Enable in Tailscale admin panel
- Verify admin approval
- Test with curl:
```bash
curl -x http://your-exit-node:8080 https://ipinfo.io
```

**High latency**
- Check network mode (kernel > userspace)
- Verify geographic proximity
- Review bandwidth limits

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Quick Start:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

**Commercial Use:** ✅ Encouraged
**Modification:** ✅ Allowed
**Redistribution:** ✅ Permitted

---

## 🔗 Related Projects

- [Tailscale](https://tailscale.com) - Our core networking provider
- [Tailscale on GitHub](https://github.com/tailscale) - Official repositories
- [Headscale](https://github.com/juanfont/headscale) - Self-hosted control server

---

<div align="center">
  <div style="margin: 20px 0;">
    <h3>🚀 Ready to Deploy Your Private Network?</h3>
    <p><strong>Choose your platform and be online in 60 seconds:</strong></p>
    
    <div style="margin: 15px 0;">
      <a href="https://railway.app/template/tailscale-node" style="margin: 0 10px;">
        <img src="https://railway.app/button.svg" height="40" width="130" alt="Deploy on Railway">
      </a>
      <a href="https://render.com/deploy" style="margin: 0 10px;">
        <img src="https://render.com/images/deploy-to-render-button.svg" height="40" width="130" alt="Deploy on Render">
      </a>
      <a href="https://heroku.com/deploy" style="margin: 0 10px;">
        <img src="https://www.herokucdn.com/deploy/button.svg" height="40" width="130" alt="Deploy on Heroku">
      </a>
    </div>
  </div>

**Questions? Join our community or open an issue.**

</div>

---

Last updated: January 2025 | AutoNode Pro v2.0.0
