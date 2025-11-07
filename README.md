<div align="center">

# 🚀 Tailscale AutoNode Setup 
# 💎 Easy Installer Script For All Platform:)



**One-click deploy. Zero config. Maximum flex.**

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Tailscale](https://img.shields.io/badge/Tailscale-100?style=for-the-badge&logo=tailscale&logoColor=white)](https://tailscale.com)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

**Just Deploy And Easy Use**

---

### ⚡ One-Click Deploy (Choose Your Weapon)

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/tailscale-node)
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)
[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)


</div>

---

## 🎯 What Does This Thing Even Do?

Imagine having a **private network that follows you everywhere**—like a VPN, but smarter, faster, and without the soul-crushing configuration files.

This project **automatically connects any server/container to your Tailscale network** with:
- 🌍 **Exit Node** capability (route ALL your traffic through it—yes, even your questionable 3am searches)
- 🤖 **Auto-detection** of location, datacenter, and country (because naming is hard)
- 🔄 **Smart fallbacks** (kernel mode → userspace mode → carrier pigeon if needed)
- 💪 **Zero manual config** (we handle the boring stuff so you can focus on... whatever you do)

### In Human Terms:

- **Developer?** Connect your cloud servers to your dev environment instantly
- **Privacy enthusiast?** Route traffic through your home server from coffee shops
- **Corporate drone?** Access internal resources without VPN hell
- **Curious tinkerer?** Because you can, and it's fun

---

## 🎨 Features That'll Make You Feel Like a Wizard

<table>
<tr>
<td width="50%">

### 🚀 **One-Click Deploy**
Click button. Enter auth key. Ship it.
*No PhD in DevOps required.*

### 🌐 **Exit Node Magic**
Route all traffic through any node.
*Coffee shop WiFi? Not today, Satan.*

### 🧠 **Smart Hostname Generation**
Auto-generates names like `Erf-AWS-US-1`.
*Better than "server-final-FINAL-v2".*

</td>
<td width="50%">

### 🔄 **Bulletproof Fallbacks**
Tries kernel mode → userspace → just works.
*Like a cat, but for networking.*

### 📊 **Beautiful Status Banner**
See all your connection details at a glance.
*Flex on your colleagues with that ASCII art.*

### 🐳 **Multi-Platform**
Runs on Docker, Railway, Render, Heroku...
*Basically everywhere except your toaster (yet).*

</td>
</tr>
</table>

---

## 🏃 Quick Start (The "I Have 3 Minutes" Version)

### Step 1: Get Your Tailscale Auth Key

Go to [Tailscale Admin](https://login.tailscale.com/admin/settings/keys) and create a **reusable** auth key.

> 💡 **Pro tip:** Enable "Reusable" so you can deploy unlimited nodes. Enable "Ephemeral" if you want them to auto-disappear when they disconnect (great for temporary servers).

### Step 2: Pick Your Poison

Click a button below, paste your auth key when asked, and watch the magic happen:

<div align="center">

| Platform | Difficulty | Exit Node | Deploy Time | Link |
|----------|-----------|-----------|-------------|------|
| 🐳 **Docker Compose** | ⭐ Easy | ✅ Full | 1 min | [Instructions](#-docker-compose-the-og) |
| 🚂 **Railway** | ⭐ Easy | ⚠️ Limited | 2 min | [Deploy](https://railway.app/new) |
| 🎨 **Render** | ⭐ Easy | ⚠️ Limited | 2 min | [Deploy](https://render.com/deploy) |
| 🟣 **Heroku** | ⭐⭐ Medium | ❌ No | 3 min | [Instructions](#-heroku-the-classic) |
| 🪁 **Fly.io** | ⭐⭐ Medium | ⚠️ Limited | 3 min | [Instructions](#%EF%B8%8F-flyio-the-edge-lord) |
| 💻 **Codespaces** | ⭐ Easy | ⚠️ Limited | 30 sec | [Instructions](#-codespaces--gitpod-the-lazy-way) |

</div>

---

## 📚 Platform Guides (For Those Who Read Instructions)

### 🐳 Docker Compose (The OG)

**Why this is the best option:** Full exit node support, runs anywhere, maximum control.

```bash
# 1. Clone this bad boy
git clone https://github.com/yourusername/tailscale-autonode
cd tailscale-autonode

# 2. Setup your auth key
cp .env.template .env
nano .env  # Add your TAILSCALE_AUTH_KEY

# 3. Launch!
docker-compose up -d

# 4. Watch the beautiful logs
docker-compose logs -f
```

**Exit Node Setup:**
1. Go to [Tailscale Admin → Machines](https://login.tailscale.com/admin/machines)
2. Find your shiny new node
3. Edit route settings → Enable "Use as exit node"
4. Profit! 💰

---

### 🚂 Railway (The Speed Demon)

**Why you'll love it:** Fastest deploy ever. Literally click and done.

```bash
# Method 1: CLI (for command line addicts)
railway up
railway vars set TAILSCALE_AUTH_KEY=tskey-auth-your-key-here

# Method 2: Button (for normal humans)
# Click the Railway button at the top ↑
# Paste your auth key
# That's it. Seriously.
```

**The catch:** Exit node works but requires manual approval (userspace mode).

---

### 🎨 Render (The Pretty One)

**Why you'll love it:** Beautiful dashboard, auto-deploys from GitHub.

**Steps:**
1. Click "Deploy to Render" button above
2. Connect your GitHub (if not already)
3. Render auto-detects `render.yaml` (we did the work for you)
4. Enter your `TAILSCALE_AUTH_KEY`
5. Click "Create Web Service"
6. Go get coffee ☕ (it'll be ready when you're back)

**The catch:** Exit node works in userspace mode (slower, but stable).

---

### 🟣 Heroku (The Classic)

**Why it's here:** Because some people never left 2015, and that's okay.

```bash
# 1. Install Heroku CLI (if you haven't already)
brew install heroku/brew/heroku  # macOS
# or: curl https://cli-assets.heroku.com/install.sh | sh

# 2. Create app with container stack
heroku create your-cool-app-name
heroku stack:set container -a your-cool-app-name

# 3. Set your auth key
heroku config:set TAILSCALE_AUTH_KEY=tskey-auth-your-key -a your-cool-app-name

# 4. Deploy
git push heroku main

# 5. Check logs (for the dopamine hit)
heroku logs --tail -a your-cool-app-name
```

**The catch:** No exit node support (Heroku doesn't give you network privileges). Still great for regular Tailscale access though!

---

### 🪁️ Fly.io (The Edge Lord)

**Why you'll love it:** Runs on the edge, ultra-low latency, very fast.

```bash
# 1. Install flyctl
curl -L https://fly.io/install.sh | sh

# 2. Login
fly auth login

# 3. Launch (it auto-detects fly.toml)
fly launch --no-deploy

# 4. Set your secret auth key
fly secrets set TAILSCALE_AUTH_KEY=tskey-auth-your-key

# 5. Deploy!
fly deploy

# 6. Watch it fly 🚀
fly logs
```

**The catch:** Exit node works but NAT might be limited. Perfect for regular Tailscale access.

---

### 💻 Codespaces / Gitpod (The Lazy Way)

**Why you'll love it:** Opens in browser. Zero install. Maximum lazy.

**Codespaces:**
1. Open this repo in Codespaces
2. Create `.env` file with your `TAILSCALE_AUTH_KEY`
3. It auto-runs on startup
4. Done! Check terminal for your fancy status banner

**Gitpod:**
1. Prefix repo URL with `gitpod.io/#`
2. Same as Codespaces
3. Profit!

**The catch:** Exit node in userspace mode. But hey, you're literally coding in a browser, so...

---

## 🎭 Exit Node: The Ultimate Power Move

### What Even Is an Exit Node?

Imagine you're at a sketchy coffee shop. Their WiFi is watching you. Judging you. Logging your every move.

**Exit node to the rescue:** All your traffic goes through YOUR server first. The coffee shop WiFi sees encrypted Tailscale traffic. Your server sees the real requests.

**Use cases:**
- 🏖️ Vacation in another country, need access to home-region services
- ☕ Coffee shop WiFi (never trust free WiFi)
- 🏢 Corporate VPN bypass (ask your IT department first... or don't)
- 🎮 Gaming from different regions (no judgment)
- 🔒 Just general privacy vibes

### How to Enable:

**Method 1: Docker Compose (Full Support)**
```bash
# Already configured in docker-compose.yml!
# Just approve in admin panel after deploy
```

**Method 2: Manual Docker**
```bash
docker run -d \
  --name tailscale-exit \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --env-file .env \
  -p 8080:8080 \
  tailscale-autonode
```

**Method 3: Cloud Platforms**
- Deploy normally
- Check logs for "Exit Node: Advertised"
- Go to [Admin Panel](https://login.tailscale.com/admin/machines)
- Enable "Use as exit node"
- Done!

> ⚠️ **Note:** Some platforms (Heroku, Replit) don't support exit nodes due to restrictions. They'll still work as regular Tailscale nodes though!

---

## 🎨 The Status Banner (Eye Candy for Nerds)

After successful deployment, you'll see this beauty:

```
╔═══════════════════════════════════════════════════════════╗
║              ✓  TAILSCALE CONNECTED SUCCESSFULLY          ║
╚═══════════════════════════════════════════════════════════╝

┌───────────────────┬───────────────────────────────────────┐
│ Parameter         │ Value                                 │
├───────────────────┼───────────────────────────────────────┤
│ Hostname          │ Erf-AWS-us-east-1-US-1
│ Tailscale IPv4    │ 100.64.0.5
│ Tailscale IPv6    │ fd7a:115c:a1e0::1
│ Public IP         │ 54.123.45.67
│ Location          │ AWS-us-east-1
│ Country           │ US
│ Exit Node         │ Advertised (Approve in Admin Panel)
│ Network Nodes     │ 3
│ Uptime            │ 00:02:15
└───────────────────┴───────────────────────────────────────┘

🔗 Admin Panel: https://login.tailscale.com/admin/machines
📊 Health Check: http://localhost:8080
```

*Frame it. Print it. Make it your wallpaper. We don't judge.*

---

## ⚙️ Environment Variables (The Config Nerd Section)

| Variable | Required? | Default | What It Does |
|----------|-----------|---------|--------------|
| `TAILSCALE_AUTH_KEY` | ✅ **YES** | - | Your magic key from [Tailscale Admin](https://login.tailscale.com/admin/settings/keys) |
| `HOSTNAME_PREFIX` | No | `Erf-` | Prefix for your hostname (e.g., `MyApp-AWS-US-1`) |
| `COUNTRY_CODE_OVERRIDE` | No | Auto-detect | Force a country code (e.g., `US`, `DE`, `JP`) |
| `HTTP_PORT` | No | `8080` | Health check port (because health checks are important, Karen) |

**Example `.env` file:**
```bash
TAILSCALE_AUTH_KEY=tskey-auth-kYourKeyHere123456789ABCDEF
HOSTNAME_PREFIX=MyCoolApp-
COUNTRY_CODE_OVERRIDE=US
HTTP_PORT=8080
```

---

## 🧠 How It Works (The Technical Bit)

```mermaid
graph LR
    A[Deploy Button] --> B[Container Starts]
    B --> C{Check Capabilities}
    C -->|Has NET_ADMIN| D[Kernel Mode + NAT]
    C -->|Restricted| E[Userspace Mode]
    D --> F[Connect to Tailscale]
    E --> F
    F --> G[Auto-detect Location]
    G --> H[Generate Hostname]
    H --> I[Advertise Exit Node]
    I --> J[Beautiful Status Banner]
    J --> K[You're Done! 🎉]
```

### Under the Hood:

1. **Start Tailscale daemon** (tries kernel mode, falls back to userspace)
2. **Setup exit node** (tries IP forwarding + NAT, silently fails if restricted)
3. **Detect environment** (AWS? GCP? Azure? Random VPS in Moldova?)
4. **Generate smart hostname** (`Prefix-Datacenter-Country-Sequence`)
5. **Connect to Tailscale** (retries, because networks are unreliable)
6. **Show off** (beautiful status banner with all the details)

**Fallback strategy:**
- Try kernel mode with iptables NAT ✅
- If fails → Try direct /proc write for IP forwarding ⚠️
- If fails → Use userspace networking ⚠️
- If fails → Connect without exit node (still useful!) ⚠️
- If that fails → You might want to check your auth key 😅

---

## 🐛 Troubleshooting (When Things Go Wrong)

### "TAILSCALE_AUTH_KEY not set"
**Solution:** You forgot step 1. Go get an auth key from [here](https://login.tailscale.com/admin/settings/keys).

### "Exit node not working"
**Checklist:**
- ✅ Did you approve it in admin panel?
- ✅ Is your platform Docker-based? (Heroku/Replit don't support exit nodes)
- ✅ Check logs for "IP forwarding unavailable" (means userspace mode)

### "Container keeps restarting"
**Common causes:**
- Invalid auth key format (must start with `tskey-auth-`)
- Auth key expired (they expire by default after 90 days)
- Network issues (can your container reach the internet?)

### "It works but no fancy banner"
**You probably deployed on a platform that doesn't show logs.** Try:
```bash
# Railway
railway logs

# Render
# Check dashboard logs

# Heroku
heroku logs --tail

# Fly.io
fly logs

# Docker
docker-compose logs -f
```

---

## 🎯 Advanced Usage (For The Brave)

### Multiple Nodes
```bash
# Deploy to multiple platforms
railway up  # Node 1
fly deploy  # Node 2
docker-compose up -d  # Node 3

# Now you have 3 exit nodes in different locations!
# Switch between them from any device
```

### Custom Hostname
```bash
# In your .env
HOSTNAME_PREFIX=SuperCoolVPN-
# Results in: SuperCoolVPN-AWS-US-1
```

### Force Country Code
```bash
# Useful if auto-detection is wrong
COUNTRY_CODE_OVERRIDE=JP
# Always shows Japan, even if server is in US
```

---

## 🤝 Contributing

Found a bug? Want to add a feature? Have a better joke for the README?

1. Fork it
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

**Please keep the jokes coming.** We measure code quality by humor density.

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file

**TL;DR:** Do whatever you want with this code. Just don't blame us if your cat starts routing traffic through it.

---

## 🙏 Acknowledgments

- **Tailscale** - For making VPNs not suck
- **Docker** - For making deployment not suck
- **Railway/Render/Fly/etc** - For making cloud hosting not suck
- **You** - For reading this far. Seriously, most people give up after the first emoji.

---

<div align="center">

### 🚀 Ready to Deploy?

Pick your platform and **become a networking wizard** in 60 seconds:

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/tailscale-node)
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)
[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

**Or just clone it:**
```bash
git clone https://github.com/yourusername/tailscale-autonode
cd tailscale-autonode
cp .env.template .env
# Add your auth key to .env
docker-compose up -d
```

---

**Made with ☕ and ✨ by developers who got tired of manual VPN configs**

*P.S. - If this saved you time, consider starring ⭐ the repo. It makes us feel good and costs you nothing.*

</div>
