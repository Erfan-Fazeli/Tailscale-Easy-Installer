# 🚀 Tailscale Exit Node - One-Click Deploy

**Deploy Tailscale exit nodes on any platform with zero configuration!**

Auto-detects server location, generates smart hostnames (US-1, FR-2, etc.), and configures everything automatically.

## ✨ Features

- 🌍 **Auto Location Detection** - Smart hostnames based on country
- 🔄 **Multi-Platform** - Codespaces, Render, Fly.io, Railway, Koyeb, Docker
- 🔒 **Secure** - No hardcoded secrets, environment variables only
- 🏥 **Health Checks** - Built-in HTTP endpoint for monitoring
- 📡 **Exit Node Ready** - Pre-configured, just approve in admin panel
- ⚡ **Zero Config** - Set one variable, deploy, done!

---

## 🔑 Prerequisites

### 1. Get Tailscale Auth Key

1. Visit [Tailscale Keys](https://login.tailscale.com/admin/settings/keys)
2. Click **Generate auth key**
3. Enable **Reusable** toggle
4. Set expiration (90 days recommended)
5. Copy the key (starts with `tskey-auth-`)

### 2. Approve Exit Node (First Time Only)

After first deployment:
1. Go to [Tailscale Machines](https://login.tailscale.com/admin/machines)
2. Find your new node (check hostname like US-1)
3. Click → **Allow as exit node**
4. ✅ All future nodes with same key auto-approved!

---

## 🚀 Quick Deploy

### GitHub Codespaces

1. **Set Secret:**
   - Repo **Settings** → **Secrets** → **Codespaces** → **New secret**
   - Name: `TAILSCALE_AUTH_KEY`
   - Value: Your auth key

2. **Create Codespace:**
   - Click **Code** → **Codespaces** → **Create codespace**
   - Wait 2 minutes - Tailscale starts automatically!

3. **View Logs:**
   ```bash
   tail -f /tmp/tailscale.log
   ```

---

### Render.com

1. Fork this repo
2. [Render Dashboard](https://dashboard.render.com/) → **New** → **Web Service**
3. Connect repo (auto-detects `render.yaml`)
4. Set env var: `TAILSCALE_AUTH_KEY`
5. Deploy!

---

### Fly.io

```bash
fly auth login
fly launch  # Uses fly.toml
fly secrets set TAILSCALE_AUTH_KEY=tskey-auth-xxxxx
fly deploy
```

---

### Docker

```bash
cp .env.example .env
nano .env  # Add TAILSCALE_AUTH_KEY
docker-compose up -d
docker-compose logs -f
```

---

## 📝 Configuration (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `TAILSCALE_AUTH_KEY` | *required* | Your Tailscale auth key |
| `HTTP_PORT` | `8080` | Health check port |
| `HOSTNAME_PREFIX` | Country code | Custom hostname prefix |
| `COUNTRY_CODE_OVERRIDE` | Auto-detect | Force specific country |

---

## 🔍 Monitoring

**Health Check:**
```bash
curl http://localhost:8080/health
```

**Status:**
```bash
# Docker
docker exec -it tailscale-exit-node tailscale status

# Codespaces
sudo tailscale status
```

**Logs:**
```bash
# Docker
docker-compose logs -f

# Codespaces
tail -f /tmp/tailscale.log
```

---

## 🛠️ Troubleshooting

**"AUTH_KEY not set"** → Set environment variable in platform settings

**Exit node not showing** → Wait 2 minutes, check logs, verify key not expired

**Container restarting** → Check logs, verify `/dev/net/tun` access

---

## 📚 How It Works

1. Detects platform (Codespaces, Render, Fly.io, etc.)
2. Gets server country from ipapi.co
3. Generates hostname like "US-abc1"
4. Starts Tailscale daemon
5. Connects with exit node enabled
6. Runs health check server
7. Keeps alive until stopped

---

**Made with ❤️ for Tailscale**

- [Tailscale Admin](https://login.tailscale.com/admin)
- [Exit Node Docs](https://tailscale.com/kb/1103/exit-nodes/)
