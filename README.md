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

### Image Tags

| Base image | Tags |
|---|---|
| `node:current-slim` (default) | `latest`, `node`, `<version>`, `<version>-node` (e.g. `1.0.0`, `1.0`, `1`, `1.0.0-node`, `1.0-node`, `1-node`) |
| `ubuntu:26.04` | `ubuntu`, `<version>-ubuntu` (e.g. `1.0.0-ubuntu`, `1.0-ubuntu`, `1-ubuntu`) |

```bash
docker pull ghcr.io/antonyho/docker-opencode:ubuntu
```

### Building Your Own Image

If you prefer to build the image yourself: (replace my namespace "antonyho" with yours)

```bash
# Build the default (node) image
docker build -t antonyho/docker-opencode .

# Build the Ubuntu 26.04 based image
docker build -f Dockerfile.ubuntu -t antonyho/docker-opencode:ubuntu .
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

## Included Development Tools

Both image variants ship with the same developer toolset on top of their base image, so OpenCode can build, search, lint, and inspect most projects without installing anything first:

| Area | Tools |
|---|---|
| Source control | `git`, `git-lfs`, `gh`, `delta` |
| Search & files | `ripgrep` (`rg`), `fd`, `fzf`, `bat`, `tree`, `file`, `rsync` |
| Data & text | `jq`, `yq`, `sed`, `grep`, `awk`, `less`, `vim`, `nano` |
| Networking | `curl`, `wget`, `ssh`, `scp`, `ping`, `dig`, `nc`, `ip`, `lsof` |
| Build | `gcc`, `g++`, `make`, `cmake`, `ninja`, `autoconf`, `automake`, `libtool`, `pkg-config`, `gdb` |
| Languages | Node.js + npm, Python 3 (`pip`, `venv`, headers), Go, Rust (`rustc`, `cargo`) |
| Utilities | `htop`, `sqlite3`, `unzip`, `zip`, `tar`, `xz`, `bzip2`, `zstd`, `shellcheck`, `shfmt`, `hyperfine`, `direnv` |

Debian/Ubuntu package `fd` and `bat` as `fdfind` and `batcat`; the images also provide `fd` and `bat` aliases. The `python` command points to `python3`.

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
