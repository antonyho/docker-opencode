FROM node:current-slim

ARG OPENCODE_VERSION=latest

ENV WORKSPACE="/workspace"
ENV HOME=$WORKSPACE/.opencode-cfg/home
ENV XDG_CONFIG_HOME=$WORKSPACE/.opencode-cfg/config
ENV XDG_DATA_HOME=$WORKSPACE/.opencode-cfg/data
ENV XDG_CACHE_HOME=$WORKSPACE/.opencode-cfg/cache
ENV XDG_STATE_HOME=$WORKSPACE/.opencode-cfg/state
WORKDIR $WORKSPACE
RUN mkdir -p $HOME $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_CACHE_HOME $XDG_STATE_HOME
RUN npm i -g opencode-ai@${OPENCODE_VERSION#v}

CMD ["opencode"]
