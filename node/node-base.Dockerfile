FROM ubuntu:24.04 as build

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ADD https://nodejs.org/dist/v20.12.2/node-v20.12.2-linux-x64.tar.gz .
RUN mkdir -p /usr/local/lib/nodejs && \
    tar -xzf node-v20.12.2-linux-x64.tar.gz \
        -C /usr/local/lib/nodejs && \
    rm node-v20.12.2-linux-x64.tar.gz

ENV PATH /app/node_modules/.bin:/usr/local/lib/nodejs/node-v20.12.2-linux-x64/bin:$PATH
RUN npm install -g npm@10.6.0

FROM ubuntu:24.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

# hadolint ignore=DL3022
COPY --from=quay.io/mynth/docker-vault-cli /usr/local/bin/vault-cli /usr/local/bin/vault-cli

RUN useradd --create-home --shell /bin/bash noddy && \
    mkdir /app && \
    chown -R noddy:noddy /app

COPY --from=build /usr/local/lib/nodejs /usr/local/lib/nodejs
ENV PATH /app/node_modules/.bin:/usr/local/lib/nodejs/node-v20.12.2-linux-x64/bin:$PATH

USER noddy
ENV NODE_ENV production
