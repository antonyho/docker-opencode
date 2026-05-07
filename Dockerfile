FROM node:current-slim

ENV WORKSPACE="/workspace"
ENV CLAUDE_CONFIG_DIR=$WORKSPACE/.opencode-cfg
WORKDIR $WORKSPACE
RUN npm i -g opencode-ai

CMD ["opencode"]
