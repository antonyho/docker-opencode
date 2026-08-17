FROM node:current-slim

ENV WORKSPACE="/workspace"
ENV XDG_CONFIG_HOME=$WORKSPACE/.opencode-cfg/config
ENV XDG_DATA_HOME=$WORKSPACE/.opencode-cfg/data
ENV XDG_CACHE_HOME=$WORKSPACE/.opencode-cfg/cache
ENV XDG_STATE_HOME=$WORKSPACE/.opencode-cfg/state
WORKDIR $WORKSPACE
RUN mkdir -p $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_CACHE_HOME $XDG_STATE_HOME
RUN npm i -g opencode-ai

CMD ["opencode"]
