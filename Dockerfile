FROM node:current-slim

ARG OPENCODE_VERSION=latest
ARG DEBIAN_FRONTEND=noninteractive

ENV WORKSPACE="/workspace"
ENV HOME=$WORKSPACE/.opencode-cfg/home
ENV XDG_CONFIG_HOME=$WORKSPACE/.opencode-cfg/config
ENV XDG_DATA_HOME=$WORKSPACE/.opencode-cfg/data
ENV XDG_CACHE_HOME=$WORKSPACE/.opencode-cfg/cache
ENV XDG_STATE_HOME=$WORKSPACE/.opencode-cfg/state
ENV LANG=C.UTF-8

WORKDIR $WORKSPACE

# Keep this package list in sync with Dockerfile.ubuntu.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg openssh-client \
        git git-lfs gh \
        jq yq \
        unzip zip xz-utils bzip2 zstd tar \
        less nano vim procps htop lsof file tree rsync \
        findutils diffutils patch \
        iproute2 iputils-ping bind9-dnsutils netcat-openbsd \
        sqlite3 \
        ripgrep fd-find fzf bat git-delta \
        hyperfine direnv shellcheck shfmt \
        build-essential pkg-config autoconf automake libtool \
        cmake ninja-build gdb \
        python3 python3-pip python3-venv python3-dev \
        golang-go rustc cargo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install --system \
    && if command -v fdfind >/dev/null 2>&1; then ln -sf "$(command -v fdfind)" /usr/local/bin/fd; fi \
    && if command -v batcat >/dev/null 2>&1; then ln -sf "$(command -v batcat)" /usr/local/bin/bat; fi \
    && ln -sf "$(command -v python3)" /usr/local/bin/python

RUN mkdir -p $HOME $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_CACHE_HOME $XDG_STATE_HOME
RUN npm i -g @opencode/cli@${OPENCODE_VERSION#v}

CMD ["opencode"]
