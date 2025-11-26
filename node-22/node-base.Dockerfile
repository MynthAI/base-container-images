FROM ubuntu:24.04 AS build

ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://nodejs.org/dist/v22.21.1/node-v22.21.1-linux-x64.tar.xz .

RUN mkdir -p /usr/local/lib/nodejs && \
    tar -xJf node-v22.21.1-linux-x64.tar.xz && \
    mv node-v22.21.1-linux-x64 /usr/local/lib/nodejs && \
    rm node-v22.21.1-linux-x64.tar.xz

ENV PATH=$PATH:/usr/local/lib/nodejs/node-v22.21.1-linux-x64/bin

FROM ubuntu:24.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

# hadolint ignore=DL3022
COPY --from=quay.io/mynth/docker-vault-cli /usr/local/bin/vault-cli /usr/local/bin/vault-cli

RUN useradd --create-home --shell /bin/bash noddy && \
    mkdir /app && \
    chown -R noddy:noddy /app

COPY --from=build /usr/local/lib/nodejs /usr/local/lib/nodejs
ENV PATH=/app/node_modules/.bin:/usr/local/lib/nodejs/node-v22.21.1-linux-x64/bin:$PATH

USER noddy
ENV NODE_ENV=production
RUN npm config set update-notifier false
