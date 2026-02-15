FROM ubuntu:24.04 AS build

ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://nodejs.org/dist/v24.13.1/node-v24.13.1-linux-x64.tar.xz .

RUN mkdir -p /usr/local/lib/nodejs && \
    tar -xJf node-v24.13.1-linux-x64.tar.xz && \
    mv node-v24.13.1-linux-x64 /usr/local/lib/nodejs && \
    rm node-v24.13.1-linux-x64.tar.xz

ENV PATH=$PATH:/usr/local/lib/nodejs/node-v24.13.1-linux-x64/bin
RUN npm install -g corepack@0.34.6 && \
    npm config set update-notifier false

FROM ubuntu:24.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

RUN useradd --create-home --shell /bin/bash noddy && \
    mkdir /app && \
    chown -R noddy:noddy /app

COPY --from=build /usr/local/lib/nodejs /usr/local/lib/nodejs
ENV PNPM_HOME=/home/noddy/.local/share/pnpm
ENV PATH=$PNPM_HOME:/app/node_modules/.bin:/usr/local/lib/nodejs/node-v24.13.1-linux-x64/bin:$PATH

# hadolint ignore=DL3008
RUN corepack enable && \
    corepack prepare pnpm@10.29.3 --activate && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g node-gyp@12.2.0 turbo@2.8.9

USER noddy
ENV NODE_ENV=development
