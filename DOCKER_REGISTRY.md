# 🐳 Docker Registry Guide - GitHub Container Registry

This document explains how to use the automated Docker image builds with GitHub Container Registry (ghcr.io).

## 📦 What This Does

The GitHub Actions workflow automatically builds and publishes Docker images to GitHub Container Registry whenever you:
- Push commits to the `main` branch
- Create version tags (e.g., `v1.0.0`)
- Open pull requests (builds only, doesn't publish)

## 🚀 Quick Start

### For Users: Pull Pre-Built Images

No setup needed! Just pull the image:

```bash
# Replace YOUR-GITHUB-USERNAME with the repository owner
docker pull ghcr.io/YOUR-GITHUB-USERNAME/tailscale-easy-installer:latest

# Run it:
docker run -d \
  -e TAILSCALE_AUTH_KEY=tskey-auth-xxxxx \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  ghcr.io/YOUR-GITHUB-USERNAME/tailscale-easy-installer:latest
```

### For Maintainers: First Time Setup

**No configuration needed!** The workflow uses `GITHUB_TOKEN` which is automatically provided by GitHub Actions.

Just push your code and the workflow runs automatically:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

The image will be built and pushed to:
```
ghcr.io/YOUR-GITHUB-USERNAME/tailscale-easy-installer:latest
```

## 🏷️ Image Tags

The workflow automatically creates multiple tags:

| Tag | Description | Example |
|-----|-------------|---------|
| `latest` | Latest commit on main branch | `ghcr.io/user/repo:latest` |
| `main` | Main branch | `ghcr.io/user/repo:main` |
| `v1.0.0` | Semantic version tags | `ghcr.io/user/repo:v1.0.0` |
| `v1.0` | Major.minor version | `ghcr.io/user/repo:v1.0` |
| `v1` | Major version | `ghcr.io/user/repo:v1` |
| `main-abc1234` | Branch with commit SHA | `ghcr.io/user/repo:main-abc1234` |
| `pr-123` | Pull request number | `ghcr.io/user/repo:pr-123` |

## 📋 How to Create a Release

Create a new version tag and push it:

```bash
# Create a tag
git tag v1.0.0

# Push the tag
git push origin v1.0.0
```

This will automatically:
1. Build the Docker image
2. Tag it as `v1.0.0`, `v1.0`, `v1`, and `latest`
3. Push to GitHub Container Registry

## 🔧 Platform-Specific Usage

### Render.com

Edit your `render.yaml`:

```yaml
services:
  - type: web
    name: tailscale-exit-node
    env: docker
    image:
      url: ghcr.io/YOUR-GITHUB-USERNAME/tailscale-easy-installer:latest
    # Remove dockerfilePath and dockerContext
```

### Docker Compose

Edit your `docker-compose.yml`:

```yaml
services:
  tailscale:
    image: ghcr.io/YOUR-GITHUB-USERNAME/tailscale-easy-installer:latest
    # Remove build section
```

### Railway.app

In Railway dashboard:
1. Create new service
2. Select "Docker Image"
3. Enter: `ghcr.io/YOUR-GITHUB-USERNAME/tailscale-easy-installer:latest`

### Fly.io

Update your `fly.toml`:

```toml
[build]
  image = "ghcr.io/YOUR-GITHUB-USERNAME/tailscale-easy-installer:latest"
```

## 🔍 Viewing Your Images

### Via GitHub Web Interface

1. Go to your repository on GitHub
2. Click on **Packages** in the right sidebar
3. You'll see your `tailscale-easy-installer` package

### Via Command Line

```bash
# List all tags
gh api /user/packages/container/tailscale-easy-installer/versions

# Or browse:
# https://github.com/YOUR-USERNAME?tab=packages
```

## 🔐 Making Your Image Public

By default, images are private. To make them public:

**Option 1: Via GitHub Web Interface**
1. Go to the package page
2. Click **Package settings**
3. Scroll to **Danger Zone**
4. Click **Change visibility**
5. Select **Public**

**Option 2: Via GitHub CLI**
```bash
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  /user/packages/container/tailscale-easy-installer/visibility \
  -f visibility='public'
```

## 🏗️ Multi-Platform Support

The workflow builds for multiple architectures:
- **linux/amd64** - Standard x86_64 (Intel/AMD)
- **linux/arm64** - ARM 64-bit (Apple Silicon, ARM servers)

This means your image will work on:
- Standard cloud VMs (AWS, GCP, Azure, DigitalOcean)
- ARM-based instances (AWS Graviton, Oracle ARM)
- Local development (Intel Macs, M1/M2/M3 Macs, ARM servers)

## 🐛 Troubleshooting

### Build Fails on Push

Check the Actions tab:
1. Go to your repository
2. Click **Actions** tab
3. Click on the failed workflow run
4. Expand the failed step to see errors

### Can't Pull Image (403 Forbidden)

Your image is private. Either:
- Make it public (see "Making Your Image Public" above)
- Authenticate with ghcr.io:
  ```bash
  echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
  ```

### Image Not Found (404)

- Check the image name matches your repository (all lowercase)
- Verify the workflow completed successfully (Actions tab)
- Wait a few minutes after first push

## 📊 Workflow Details

The workflow (`.github/workflows/docker-build-push.yml`) does:

1. **Checkout code** - Gets your latest code
2. **Setup QEMU** - Enables multi-architecture builds
3. **Setup Docker Buildx** - Advanced Docker build features
4. **Login to ghcr.io** - Uses automatic `GITHUB_TOKEN`
5. **Extract metadata** - Creates tags and labels automatically
6. **Build & Push** - Builds for amd64 & arm64, pushes to registry
7. **Cache layers** - Speeds up subsequent builds

## 🔄 CI/CD Integration

The workflow runs on:
- ✅ Push to `main` - Builds and publishes `latest`
- ✅ Version tags - Builds and publishes versioned images
- ✅ Pull requests - Builds only (for testing)
- ❌ Other branches - No action

## 💡 Pro Tips

### Pin to Specific Version (Recommended for Production)

Instead of `latest`, use semantic versions:

```yaml
image: ghcr.io/YOUR-USERNAME/tailscale-easy-installer:v1.0.0
```

This ensures:
- Predictable deployments
- Easy rollbacks
- No surprise breaking changes

### Auto-Update with Renovate/Dependabot

Add this to `.github/renovate.json`:

```json
{
  "extends": ["config:base"],
  "docker": {
    "enabled": true
  }
}
```

### Local Testing Before Push

Test your changes locally:

```bash
# Build locally
docker build -t test .

# Run it
docker run -d -e TAILSCALE_AUTH_KEY=xxx test

# If it works, push to trigger workflow
git push
```

## 📚 Additional Resources

- [GitHub Container Registry Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Multi-Platform Builds](https://docs.docker.com/build/building/multi-platform/)

## 🆘 Support

- **GitHub Issues**: Report bugs or request features
- **GitHub Discussions**: Ask questions and share tips
- **Workflow Logs**: Check Actions tab for detailed build logs

---

**Questions?** Open an issue or check the workflow file: [`.github/workflows/docker-build-push.yml`](.github/workflows/docker-build-push.yml)
