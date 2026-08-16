FROM ubuntu:26.04 AS build

ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://nodejs.org/dist/v26.7.0/node-v26.7.0-linux-x64.tar.xz .

RUN mkdir -p /usr/local/lib/nodejs && \
    tar -xJf node-v26.7.0-linux-x64.tar.xz && \
    mv node-v26.7.0-linux-x64 /usr/local/lib/nodejs && \
    rm node-v26.7.0-linux-x64.tar.xz

ENV PATH=$PATH:/usr/local/lib/nodejs/node-v26.7.0-linux-x64/bin

FROM ubuntu:26.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

RUN useradd --create-home --shell /bin/bash noddy && \
    mkdir /app && \
    chown -R noddy:noddy /app

# Node.js 26 requires libatomic.so.1
# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libatomic1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/lib/nodejs /usr/local/lib/nodejs
ENV PATH=/app/node_modules/.bin:/usr/local/lib/nodejs/node-v26.7.0-linux-x64/bin:$PATH

# hadolint ignore=DL3066
USER noddy
ENV NODE_ENV=production
RUN npm config set update-notifier false
