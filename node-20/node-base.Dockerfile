FROM ubuntu:24.04 as build

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://nodejs.org/dist/v20.5.1/node-v20.5.1-linux-x64.tar.xz .

RUN mkdir -p /usr/local/lib/nodejs && \
    tar -xJf node-v20.5.1-linux-x64.tar.xz && \
    mv node-v20.5.1-linux-x64 /usr/local/lib/nodejs && \
    rm node-v20.5.1-linux-x64.tar.xz

ENV PATH $PATH:/usr/local/lib/nodejs/node-v20.5.1-linux-x64/bin
RUN npm install -g npm@10.7.0

FROM ubuntu:24.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

# hadolint ignore=DL3022
COPY --from=quay.io/mynth/docker-vault-cli /usr/local/bin/vault-cli /usr/local/bin/vault-cli

RUN useradd --create-home --shell /bin/bash noddy && \
    mkdir /app && \
    chown -R noddy:noddy /app

COPY --from=build /usr/local/lib/nodejs /usr/local/lib/nodejs
ENV PATH /app/node_modules/.bin:/usr/local/lib/nodejs/node-v20.5.1-linux-x64/bin:$PATH

USER noddy
ENV NODE_ENV production
RUN npm config set update-notifier false
