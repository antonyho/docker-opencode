#!/bin/sh
# Installs the developer toolset into an image. Shared by Dockerfile and
# Dockerfile.ubuntu so the two variants cannot drift apart.
#
# Usage: install-tools.sh <core|full> [extra apt packages...]
#
#   core  What the agent reaches for in almost every project: version control,
#         search, structured data, fetching, archives, and a C/C++ compiler so
#         npm/pip packages with native modules can install.
#   full  core + language toolchains (Go, Rust) and native build/debug tools.
#
# Env: YQ_VERSION (default "latest"), RUSTUP_HOME and CARGO_HOME (full only).
set -eu

TOOLSET="${1:-core}"
[ "$#" -gt 0 ] && shift

CORE="
  ca-certificates curl openssh-client
  git git-lfs gh
  ripgrep fd-find jq
  less procps file tree patch
  unzip zip xz-utils
  build-essential
  python3 python3-venv
"

FULL="
  pkg-config autoconf automake libtool cmake ninja-build gdb
  python3-dev python3-pip
  golang-go
  shellcheck shfmt sqlite3
"

case "$TOOLSET" in
  core) PKGS="$CORE" ;;
  full) PKGS="$CORE $FULL" ;;
  *) echo "install-tools.sh: unknown toolset '$TOOLSET' (expected core or full)" >&2; exit 1 ;;
esac

apt-get update
# shellcheck disable=SC2086 # word splitting of the package lists is intended
apt-get install -y --no-install-recommends $PKGS "$@"
rm -rf /var/lib/apt/lists/*

# Git: LFS hooks for everyone, and no "dubious ownership" errors when the
# container user differs from the owner of the mounted repository.
git lfs install --system
git config --system --add safe.directory '*'

# Debian/Ubuntu ship fd as fdfind; provide the usual name. Same for python.
ln -sf "$(command -v fdfind)" /usr/local/bin/fd
ln -sf "$(command -v python3)" /usr/local/bin/python

# mikefarah/yq (the Go yq most docs and agents assume). Debian's "yq" package
# is a different, jq-wrapper tool with incompatible syntax.
ARCH="$(dpkg --print-architecture)"
YQ_VERSION="${YQ_VERSION:-latest}"
if [ "$YQ_VERSION" = latest ]; then
  YQ_URL="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}"
else
  YQ_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}"
fi
curl -fsSL "$YQ_URL" -o /usr/local/bin/yq
chmod 0755 /usr/local/bin/yq

if [ "$TOOLSET" = full ]; then
  # Current stable Rust via rustup; the distro rustc lags many releases behind
  # and has no way to upgrade from inside the container.
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs \
    | sh -s -- -y --no-modify-path --profile minimal --default-toolchain stable
  # The container runs as an arbitrary host UID; let it use the cargo registry
  # cache and add components.
  chmod -R a+rwX "$RUSTUP_HOME" "$CARGO_HOME"
fi
