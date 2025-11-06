╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║         🚀 Tailscale Exit Node - GitHub Codespaces 🚀        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

✅ Codespace is ready!

📋 IMPORTANT: Configure your Tailscale Auth Key
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You need to set your TAILSCALE_AUTH_KEY as a Codespace Secret:

1. Go to: https://github.com/settings/codespaces
2. Click "New secret"
3. Name: TAILSCALE_AUTH_KEY
4. Value: Your auth key from https://login.tailscale.com/admin/settings/keys
   (Should start with: tskey-auth-...)
5. Click "Add secret"
6. Rebuild this Codespace

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Quick Start Commands:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Start Tailscale (recommended - shows all logs):
  $ ./run-tailscale.sh

  OR start manually:
  $ sudo /usr/local/bin/start.sh

  Check if running:
  $ sudo tailscale status

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Notes:
  - Tailscale will auto-start when Codespace starts
  - All logs will be visible in the Terminal
  - Health check available at: http://localhost:8080/health

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
