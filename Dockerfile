FROM node:current-slim

ARG DEBIAN_FRONTEND=noninteractive
# core: what the agent needs in most projects. full: adds Go, Rust and native
# build/debug tools. See scripts/install-tools.sh.
ARG TOOLSET=core
ARG YQ_VERSION=latest

ENV WORKSPACE="/workspace"
ENV HOME=$WORKSPACE/.opencode-cfg/home
ENV XDG_CONFIG_HOME=$WORKSPACE/.opencode-cfg/config
ENV XDG_DATA_HOME=$WORKSPACE/.opencode-cfg/data
ENV XDG_CACHE_HOME=$WORKSPACE/.opencode-cfg/cache
ENV XDG_STATE_HOME=$WORKSPACE/.opencode-cfg/state
ENV LANG=C.UTF-8
# Toolchain locations (used by the "full" toolset; harmless otherwise).
# GOFLAGS keeps Go's module cache deletable, GOTOOLCHAIN lets Go fetch the
# version a project's go.mod asks for.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    GOFLAGS=-modcacherw \
    GOTOOLCHAIN=auto

WORKDIR $WORKSPACE

RUN --mount=type=bind,source=scripts/install-tools.sh,target=/tmp/install-tools.sh \
    sh /tmp/install-tools.sh "$TOOLSET"

RUN mkdir -p $HOME $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_CACHE_HOME $XDG_STATE_HOME

# Declared here, not at the top, so a new OpenCode version only rebuilds this
# layer and the toolchain layers above stay cached and shared between tags.
ARG OPENCODE_VERSION=latest
RUN npm i -g @opencode/cli@${OPENCODE_VERSION#v}

CMD ["opencode"]
