# Tailscale Auto-Setup Deployment Guide

## 🚀 Quick Deployment to Render.com

### Step 1: Update Environment Variable in Render

1. Go to your Render dashboard: https://dashboard.render.com
2. Select your service: `tailscale-exit-node` (or similar)
3. Click on **Environment** tab
4. Find `TAILSCALE_AUTH_KEY` and update it to:
   ```
   tskey-auth-kq9G185aP311CNTRL-MLdgjrxL6wgStDBj4P93wg7y8QNx8cEV9
   ```
5. Click **Save Changes**
6. Render will automatically redeploy your service

### Step 2: Monitor Deployment Logs

Watch the deployment logs for these success indicators:

```
✓ Found and cleaned TAILSCALE_AUTH_KEY
Auth key length: 62
✓ Auth key written to file: /tmp/tailscale-authkey
File size: 62 bytes
AutoDeploy: Method 1 - Using --authkey with direct key from file...
✓ Authentication successful with direct key method!
══ TAILSCALE CONNECTED ══
Hostname: Erf-...
Tailscale IP: 100.x.x.x
Status: <your-machine-name>; ...
```

### Step 3: Verify Connection

After successful deployment:

1. Go to Tailscale Admin Console: https://login.tailscale.com/admin/machines
2. Look for your new node (hostname will be `Erf-*-*-*-*`)
3. Verify it shows as **"Connected"**
4. Check that it's advertising as an **exit node**

---

## 🔧 Troubleshooting

### If Authentication Still Fails

Run the diagnostic tool locally:
```bash
./verify-authkey.sh
```

This will check:
- ✓ Auth key format
- ✓ Key length (should be 60-65 characters)
- ✓ No invalid characters
- ✓ Proper structure

### Common Issues

#### Issue: "invalid key" error
**Solution**: The auth key is expired or revoked
- Generate a new key at: https://login.tailscale.com/admin/settings/keys
- Make sure to enable "Reusable" and set expiration to 90+ days

#### Issue: Authentication hanging
**Solution**: Now fixed with timeout flags
- The latest code has 10-second timeouts on all auth attempts
- Falls back to alternative methods if one fails

#### Issue: "Logged out" status
**Solution**: Check auth key permissions
- Ensure the key has "Exit node" permissions if needed
- Verify the key is for the correct Tailnet

---

## 📋 Auth Key Best Practices

When creating a new Tailscale auth key:

1. **Reusable**: `ON` (allows multiple node registrations)
2. **Ephemeral**: `ON` (nodes auto-delete when offline - recommended for containers)
3. **Pre-approved**: `ON` (skip manual approval step)
4. **Expiration**: `90 days` or `Never` (for long-term deployments)
5. **Tags**: Optional (use for ACL policies if needed)

---

## 🛠️ Files Overview

### Core Files
- `entrypoint.sh` - Entry point that creates auth key file
- `AutoDeploy.sh` - Main deployment script with authentication logic
- `healthApi.py` - HTTP health check server (port 10000)
- `Dockerfile` - Container build configuration
- `render.yaml` - Render.com deployment configuration

### Helper Files
- `verify-authkey.sh` - Diagnostic tool for auth key validation
- `.env` - Local environment variables (NOT committed to git)
- `DEPLOYMENT_GUIDE.md` - This file

---

## 📊 How Authentication Works

1. **entrypoint.sh** loads `TAILSCALE_AUTH_KEY` from environment
2. Writes the key to a secure file: `/tmp/tailscale-authkey` (chmod 600)
3. **AutoDeploy.sh** reads the key from the file
4. Tries 3 authentication methods in sequence:
   - **Method 1**: Full-featured (exit-node, accept-routes, operator)
   - **Method 2**: Simplified (without operator flag)
   - **Method 3**: With --reset flag (clears previous attempts)
5. Each method has a 10-second timeout to prevent hanging
6. Success = Tailscale connected with exit node advertising

---

## 🔐 Security Notes

- Auth keys are stored in `/tmp/tailscale-authkey` with 600 permissions
- Keys are never logged in full (only first/last characters shown)
- The `.env` file is in `.gitignore` (never committed)
- Render environment variables are encrypted at rest

---

## 📞 Support

If you continue to have issues:

1. Check Tailscale status: https://status.tailscale.com
2. Review Render logs for detailed error messages
3. Verify your Tailscale account has active subscription
4. Check that your auth key is listed in: https://login.tailscale.com/admin/settings/keys

---

**Last Updated**: 2025-11-07
**Auth Key Updated**: 2025-11-07 (62 characters, expires in 90 days)
