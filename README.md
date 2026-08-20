# OpenCode in Docker Container

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

Then run your own image — note the tag here matches what you just built, not the `ghcr.io/...` image from Quick Start above:

```bash
docker run -it --rm \
    --name opencode \
    --userns=host \
    -u $(id -u):$(id -g) \
    -v $(pwd):/workspace \
    -w /workspace \
    antonyho/docker-opencode
```

## How It Works

### Global Config Location
The image points OpenCode's [XDG base directories](https://specifications.freedesktop.org/basedir/latest/) at `$WORKSPACE/.opencode-cfg` instead of the container user's home directory:

- `XDG_CONFIG_HOME` → `.opencode-cfg/config` (`opencode.json`, theme, etc.)
- `XDG_DATA_HOME` → `.opencode-cfg/data` (`auth.json` credentials, logs, git snapshots)
- `XDG_CACHE_HOME` → `.opencode-cfg/cache` (downloaded binaries, cache)
- `XDG_STATE_HOME` → `.opencode-cfg/state` (session locks/state)

This means OpenCode's account config, including your provider credentials, ends up stored in the mounted project directory instead of disappearing with the container.

`HOME` is also redirected to `.opencode-cfg/home`. OpenCode runs a legacy-config check against `$HOME/.opencode` on startup that isn't governed by the XDG variables above, so `HOME` must point somewhere the container user can actually write to — the default `$HOME` (the image's built-in user's home directory) isn't guaranteed to be, especially when running with `-u $(id -u):$(id -g)` as a different UID than the one that built the image.

### First Launch Setup
On first launch, OpenCode will ask for your theme preference and populate `.opencode-cfg` with the subdirectories above.

### Directory Structure
- Current directory - Mounted to `/workspace` for code access
- `.opencode-cfg` directory is created by the image and populated by OpenCode on first launch

*Add the `.opencode-cfg` directory to your project's `.gitignore` to keep your OpenCode session (including credentials) private.*

### Permission Handling
The Docker run command includes specific flags to handle file permissions:
- `--userns=host` - Disables user namespace isolation
- `-u $(id -u):$(id -g)` - Runs container with your host user/group IDs

This prevents permission issues when OpenCode creates files in mounted volumes.
**If your Docker daemon is not configured to use user namespaces, `--userns=host` and `-u $(id -u):$(id -g)` are usually not required.**
