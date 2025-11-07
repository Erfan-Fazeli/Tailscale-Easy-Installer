<div align="center">

# 🚀 Tailscale AutoNode Pro
### Enterprise-Grade Network Automation

**Deploy private networks in minutes, not days. Zero configuration required.**

[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat)](LICENSE)
[![Docker Cloud](https://img.shields.io/docker/cloud/build/tailscale/tailscale.svg?style=flat)](https://hub.docker.com/r/tailscale/tailscale)
[![Release](https://img.shields.io/github/v/release/tailscale/tailscale?style=flat)](https://github.com/tailscale/tailscale/releases)

<a href="https://railway.app/template/tailscale-node"><img src="https://railway.app/button.svg" height="32" alt="Deploy on Railway"></a>
<a href="https://render.com/deploy"><img src="https://render.com/images/deploy-to-render-button.svg" height="32" alt="Deploy to Render"></a>
<a href="https://heroku.com/deploy"><img src="https://www.herokucdn.com/deploy/button.svg" height="32" alt="Deploy to Heroku"></a>

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

</div>

<a href="https://railway.app/template/tailscale-node"><img src="https://railway.app/button.svg" height="40" alt="Deploy on Railway"></a>
<a href="https://render.com/deploy"><img src="https://render.com/images/deploy-to-render-button.svg" height="40" alt="Deploy to Render"></a>
<a href="https://heroku.com/deploy"><img src="https://www.herokucdn.com/deploy/button.svg" height="40" height="40" alt="Deploy to Heroku"></a>

---

## 📋 Platform-Specific Setup

### 🐳 Docker Compose (Recommended)
```bash
# Clone and configure
git clone https://github.com/yourusername/tailscale-autonode
cd tailscale-autonode
cp .env.template .env

# Add your auth key to .env file
echo "TAILSCALE_AUTH_KEY=tskey-auth-your-key-here" >> .env

# Deploy
docker-compose up -d

# Monitor
docker-compose logs -f
```

### 🚂 Railway
```bash
# CLI deployment
railway init
railway up
railway vars set TAILSCALE_AUTH_KEY=tskey-auth-your-key-here

# OR: Use the Railway button above
```

### 🎨 Render
1. Click "Deploy to Render" button
2. Connect GitHub repository
3. Enter `TAILSCALE_AUTH_KEY` environment variable
4. Deploy!

### 🟣 Heroku
```bash
heroku create your-app-name
heroku config:set TAILSCALE_AUTH_KEY=tskey-auth-your-key-here
git push heroku main
```

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

### 🚀 Ready to Deploy Your Private Network?

**Choose your platform and be online in 60 seconds:**

<a href="https://railway.app/template/tailscale-node"><img src="https://railway.app/button.svg" height="50" alt="Deploy on Railway"></a>
<a href="https://render.com/deploy"><img src="https://render.com/images/deploy-to-render-button.svg" height="50" alt="Deploy to Render"></a>
<a href="https://heroku.com/deploy"><img src="https://www.herokucdn.com/deploy/button.svg" height="50" alt="Deploy to Heroku"></a>

**Questions? Join our community or open an issue.**

</div>

---

Last updated: January 2025 | AutoNode Pro v2.0.0
