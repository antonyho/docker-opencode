FROM node:current-slim

ENV WORKSPACE="/workspace"
ENV OPENCODE_CONFIG_DIR=$WORKSPACE/.opencode-cfg
WORKDIR $WORKSPACE
RUN npm i -g opencode-ai

CMD ["opencode"]
