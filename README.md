# docker-opencode

## OpenCode in Docker Container

A Docker containerization of the OpenCode CLI programming agent for easy deployment and consistent environment setup.

## Prerequisites

- Docker installed and running

## Quick Start

### Using the Pre-built Image

```bash
# Run OpenCode in Docker
docker run -it --rm \
    --name opencode \
    --userns=host \
    -u $(id -u):$(id -g) \
    -v $(pwd):/workspace \
    -w /workspace \
    ghcr.io/antonyho/docker-opencode
```

### Building Your Own Image

If you prefer to build the image yourself: (replace my namespace "antonyho" with yours)

```bash
# Build the image
docker build -t antonyho/docker-opencode .
```

## How It Works

### First Launch Setup
On first launch, OpenCode will:
1. Ask for your theme preference
2. Create a `.opencode-cfg` directory in your current directory

### Directory Structure
- Current directory - Mounted to `/workspace` for code access
- `.opencode-cfg` directory will be initialised by OpenCode on first launch

*Consider adding the `.opencode-cfg` directory to your project's `.gitignore` to keep your OpenCode session private.*

### Permission Handling
The Docker run command includes specific flags to handle file permissions:
- `--userns=host` - Disables user namespace isolation
- `-u $(id -u):$(id -g)` - Runs container with your host user/group IDs

This prevents permission issues when OpenCode creates files in mounted volumes.
**If your Docker daemon is not configured to use user namespaces, `--userns=host` and `-u $(id -u):$(id -g)` are usually not required.**
