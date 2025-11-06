# 🚀 Tailscale Auto-Installer - Multi-Platform Exit Node

**One-click Tailscale exit node deployment for any containerized platform!**

Automatically installs Tailscale, connects to your network, configures as an exit node, and generates smart hostnames based on server location and number.

## ✨ Features

- 🌍 **Automatic Location Detection** - Detects server country and assigns smart hostnames (US-1, FR-2, etc.)
- 🔄 **Multi-Platform Support** - Works on GitHub Codespaces, Render.com, Fly.io, Koyeb, Railway, Docker
- 🔒 **Secure by Design** - No hardcoded secrets, uses environment variables
- 🏥 **Health Check Endpoint** - Built-in HTTP server for platform health checks
- 🔁 **Retry Logic** - Automatic retry with exponential backoff
- 📡 **Exit Node Ready** - Pre-configured for exit node usage
- 🎯 **Zero Configuration** - Just set one environment variable and deploy!
- ⚡ **Smart Resource Management** - Codespaces auto-stops to save hours, other platforms run 24/7

📖 **[Platform-Specific Behavior Guide](PLATFORM_BEHAVIOR.md)** - Learn how the installer behaves on each platform and why

---

## 🚀 Quick Start (Docker/Docker Compose)

### Method 1: Fully Automated (One Command!)

```bash
# Just run this - NO user input required!
./auto-deploy.sh
```

This script:
- ✅ Checks configuration
- ✅ Builds container
- ✅ Starts Tailscale
- ✅ Shows status
- ✅ Completely automated!

### Method 2: Manual Setup

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit and add your AUTH_KEY
nano .env

# 3. Start container
docker-compose up -d

# 4. Check logs
docker-compose logs -f
```

### Method 3: Interactive Setup

```bash
# Interactive configuration wizard
./setup.sh

# Then deploy
./quick-start.sh
```

---

## 🔑 Prerequisites

### Generate Tailscale Auth Key

You need a **Reusable** auth key from Tailscale:

1. Go to [Tailscale Admin Console → Settings → Keys](https://login.tailscale.com/admin/settings/keys)
2. Click **Generate auth key**
3. Configure:
   - ✅ **Reusable** (toggle ON) - allows multiple deployments
   - **Expiration**: 90 days (recommended)
4. Copy the generated key (starts with `tskey-auth-`)

### Exit Node Approval

Exit nodes require one-time manual approval:

1. Deploy your first exit node (using above Quick Start)
2. Go to [Tailscale Admin → Machines](https://login.tailscale.com/admin/machines)
3. Find your new node (check hostname, e.g., US-1)
4. Click on the machine → Look for "Exit Node" section
5. Click **"Allow"** or **"Approve as exit node"**
6. ✅ Done! All future nodes with the same key will auto-work

**Advanced:** For auto-approval, configure [Tailscale ACLs](https://login.tailscale.com/admin/acls) with `autoApprovers`.

---

## 🚀 Deployment Guides

### 🔷 GitHub Codespaces (Best for Testing)

**Step 1:** Set up secret
1. Go to your repository **Settings** → **Secrets and variables** → **Codespaces**
2. Click **New repository secret**
3. Name: `TAILSCALE_AUTH_KEY`
4. Value: Your auth key (from https://login.tailscale.com/admin/settings/keys)
5. Click **Add secret**

**Step 2:** Create Codespace
1. Click **Code** → **Codespaces** → **Create codespace**
2. Wait for Codespace to initialize (~2-3 minutes)
3. You'll see a welcome message with instructions

**Step 3:** Start Tailscale
```bash
# In the Codespace terminal, run:
./run-tailscale.sh
```

This will:
- ✅ Start Tailscale daemon
- ✅ Connect to your network
- ✅ Enable exit node
- ✅ Show all logs in real-time in the terminal

**Step 4:** Verify
```bash
# Check Tailscale status
sudo tailscale status

# Check health endpoint
curl http://localhost:8080/health
```

**💡 Notes:**
- All logs are displayed directly in the terminal (no hidden output!)
- Codespaces auto-stops when idle to save your usage hours
- Tailscale will reconnect automatically when you restart the Codespace

---

### 🔷 Render.com (Free Tier, 24/7)

**Step 1:** Fork/Clone this repository

**Step 2:** Connect to Render
1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click **New** → **Web Service**
3. Connect your repository
4. Render will auto-detect `render.yaml`

**Step 3:** Set environment variable
1. In the **Environment** tab, add:
   - Key: `TAILSCALE_AUTH_KEY`
   - Value: Your auth key
2. Click **Save Changes**

**Step 4:** Deploy
- Render will automatically deploy
- Check logs to see connection status
- Health endpoint: `https://your-app.onrender.com/health`

---

### 🔷 Fly.io (Global Coverage)

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login and launch
fly auth login
fly launch

# Set secret
fly secrets set TAILSCALE_AUTH_KEY=tskey-auth-xxxxxxxxxxxxxxxxxxxxx

# Deploy
fly deploy

# Check status
fly logs
fly status
```

---

### 🔷 Docker / Docker Compose (Self-Hosted)

**Option 1: Automated (Easiest)**
```bash
git clone <your-repo-url>
cd Tailscale_Installer
./setup.sh          # Interactive setup
./quick-start.sh    # Start container
```

**Option 2: Manual**
```bash
git clone <your-repo-url>
cd Tailscale_Installer
cp .env.example .env
nano .env  # Add your AUTH_KEY
docker-compose up -d
docker-compose logs -f
```

**Useful Commands:**
```bash
# Check Tailscale status
docker exec -it tailscale-exit-node sudo tailscale status

# View health endpoint
curl http://localhost:8080/health

# Stop container
docker-compose down

# Restart
docker-compose restart
```

---

## ⚙️ Configuration Options

All configuration is in `.env` file or environment variables:

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `TAILSCALE_AUTH_KEY` | Your Tailscale auth key | `tskey-auth-xxxxx` |

### Optional

| Variable | Default | Description |
|----------|---------|-------------|
| `HOSTNAME_PREFIX` | _(none)_ | Custom prefix (e.g., `myserver-US-1`) |
| `COUNTRY_CODE_OVERRIDE` | _(auto)_ | Force country code (`US`, `FR`) |
| `HTTP_PORT` | `8080` | Health check server port |
| `ENABLE_LOGGING` | `true` | Detailed logging |
| `MAX_RETRIES` | `5` | Connection retry attempts |
| `COUNTRY_LOOKUP_TIMEOUT` | `5` | Country detection timeout (seconds) |

---

## 🏥 Health Check Endpoint

```bash
curl http://localhost:8080/health
```

**Response:**
```json
{
  "status": "healthy",
  "platform": "docker",
  "tailscale": "connected",
  "ip": "100.64.0.1",
  "hostname": "US-1"
}
```

---

## 🎯 Hostname Convention

Hostnames are auto-generated:

- Format: `COUNTRY-NUMBER` or `PREFIX-COUNTRY-NUMBER`
- Examples: `US-1`, `US-2`, `FR-1`, `myserver-US-1`
- Sequential numbering per country

---

## 🌐 Using Your Exit Nodes

### On Desktop/Mobile:

1. Open Tailscale app
2. Click **"Exit Node"** or **"Use Exit Node"**
3. Select your node (e.g., `US-1`)
4. Done! Traffic routes through that server

### Via Command Line:

```bash
# Use exit node
tailscale set --exit-node=US-1

# Or by IP
tailscale set --exit-node=100.64.0.1

# Stop using exit node
tailscale set --exit-node=

# Verify IP changed
curl https://ipinfo.io/country
```

### Use Cases:

- 🌍 Access geo-restricted content
- 🔒 Secure public WiFi
- 🏢 Access region-specific services
- 🧪 Test from different locations

---

## 🔧 Troubleshooting

### Connection fails

**Check AUTH_KEY:**
```bash
# Docker
docker-compose exec tailscale-exit-node env | grep TAILSCALE

# Codespaces
echo $TAILSCALE_AUTH_KEY
```

### Exit node needs approval

**This is normal!** First-time setup requires manual approval:

1. Go to [Tailscale Admin → Machines](https://login.tailscale.com/admin/machines)
2. Find your node (hostname: e.g., US-1)
3. Click → "Exit Node" section → Click **"Allow"**
4. Done! Future nodes with same key auto-work

### Country detection fails (shows XX-1)

```bash
# Test connectivity
curl https://ipinfo.io/country

# Or override in .env
COUNTRY_CODE_OVERRIDE=US
```

### Codespaces stops after setup

**Expected behavior!** Saves your usage hours. Tailscale reconnects on restart.

```bash
# Verify connection anytime
sudo tailscale status
```

### Container keeps restarting

1. Check logs: `docker-compose logs`
2. Verify `NET_ADMIN` capability is available
3. Test health endpoint: `curl http://localhost:8080/health`

---

## 📊 Platform Compatibility

| Platform | Status | Notes |
|----------|--------|-------|
| GitHub Codespaces | ✅ Fully Supported | Auto-stops to save hours |
| Render.com | ✅ Fully Supported | Free tier, 24/7 |
| Fly.io | ✅ Fully Supported | Global coverage, 24/7 |
| Koyeb | ✅ Supported | May need config |
| Railway | ✅ Supported | Quick deploys |
| Docker | ✅ Fully Supported | Full control |
| Docker Compose | ✅ Fully Supported | Easiest setup |

---

## 🔒 Security Best Practices

1. ✅ **Never commit .env** - Protected by `.gitignore`
2. ✅ **Use reusable keys** - For multiple deployments
3. ✅ **Rotate keys regularly** - Every 90 days
4. ✅ **Keep repository private** - If storing configs
5. ✅ **Use platform secrets** - For cloud deployments

---

## 📁 Project Structure

```
.
├── .devcontainer/
│   ├── Dockerfile              # Container configuration
│   ├── devcontainer.json       # Codespaces settings
│   └── start.sh                # Main automation script (350+ lines)
│
├── .env.example                # Configuration template
├── .env                        # Your config (gitignored)
├── .gitignore                  # Protects secrets
├── docker-compose.yml          # Docker deployment
├── render.yaml                 # Render.com config
├── fly.toml                    # Fly.io config
├── auto-deploy.sh              # ⭐ Fully automated deployment (RECOMMENDED)
├── setup.sh                    # Interactive setup script
├── quick-start.sh              # Quick start with validation
├── PLATFORM_BEHAVIOR.md        # Platform behavior guide
└── README.md                   # This file
```

---

## 🛠️ Helper Scripts

### `auto-deploy.sh` - Fully Automated Deployment ⭐ RECOMMENDED
```bash
./auto-deploy.sh
```
**Complete automation - NO user input required!**
- ✅ Checks configuration
- ✅ Builds and starts container
- ✅ Shows logs and status
- ✅ One command does everything!

### `setup.sh` - Interactive Setup Wizard
```bash
./setup.sh
```
Interactive Q&A to create `.env` file with your AUTH_KEY.

### `quick-start.sh` - Quick Deployment
```bash
./quick-start.sh
```
Validates config and starts container with helpful output.

---

## 💡 Recommended Deployment Strategy

### For Testing:
- ✅ GitHub Codespaces (free, auto-stops)

### For Production Exit Nodes:
- ✅ Render.com (free tier, US/EU, 24/7)
- ✅ Fly.io (free tier, global regions, 24/7)

### For Multiple Regions:
```
US-1, US-2  → Render.com (US region)
FR-1        → Fly.io (Paris)
DE-1        → Fly.io (Frankfurt)
SG-1        → Fly.io (Singapore)
```

All within free tiers! 🎉

---

## 🤝 Contributing

Contributions welcome! Open an issue or submit a pull request.

---

## 📄 License

MIT License - free for personal and commercial use.

---

## 🙏 Acknowledgments

- [Tailscale](https://tailscale.com/) - Zero-config VPN
- Cloud platforms for generous free tiers

---

**Made with ❤️ for easy Tailscale deployment**

🔗 [Report Issues](https://github.com/your-username/Tailscale_Installer/issues)
