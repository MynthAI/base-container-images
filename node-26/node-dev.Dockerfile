FROM ubuntu:26.04 AS build

ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends xz-utils libatomic1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://nodejs.org/dist/v26.7.0/node-v26.7.0-linux-x64.tar.xz .

RUN mkdir -p /usr/local/lib/nodejs && \
    tar -xJf node-v26.7.0-linux-x64.tar.xz && \
    mv node-v26.7.0-linux-x64 /usr/local/lib/nodejs && \
    rm node-v26.7.0-linux-x64.tar.xz

ENV PATH=$PATH:/usr/local/lib/nodejs/node-v26.7.0-linux-x64/bin
RUN npm install -g corepack@0.35.0 && \
    npm config set update-notifier false

FROM ubuntu:26.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

RUN useradd --create-home --shell /bin/bash noddy && \
    mkdir /app && \
    chown -R noddy:noddy /app

COPY --from=build /usr/local/lib/nodejs /usr/local/lib/nodejs
ENV PNPM_HOME=/home/noddy/.local/share/pnpm
ENV PATH=$PNPM_HOME:/app/node_modules/.bin:/usr/local/lib/nodejs/node-v26.7.0-linux-x64/bin:$PATH

# Node.js 26 requires libatomic.so.1, so apt runs before corepack/npm
# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libatomic1 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    corepack enable && \
    corepack prepare pnpm@11.22.0 --activate && \
    npm install -g node-gyp@13.0.1 turbo@2.10.10

# hadolint ignore=DL3066
USER noddy
ENV NODE_ENV=development
