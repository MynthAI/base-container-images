FROM ubuntu:26.04 AS build

ARG FNM_VERSION=1.39.0
ARG NODE_VERSION=26.7.0
# Keep this path identical in all stages: fnm stores the default-version
# alias as an absolute symlink, so it must resolve to the same location.
ENV FNM_DIR=/usr/local/share/fnm

ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ADD https://github.com/Schniz/fnm/releases/download/v${FNM_VERSION}/fnm-linux.zip .

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends ca-certificates unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    unzip fnm-linux.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/fnm && \
    rm fnm-linux.zip

RUN fnm install ${NODE_VERSION} && \
    fnm default ${NODE_VERSION}

ENV PATH=$FNM_DIR/aliases/default/bin:$PATH

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

COPY --from=build /usr/local/bin/fnm /usr/local/bin/fnm
COPY --from=build /usr/local/share/fnm /usr/local/share/fnm
ENV FNM_DIR=/usr/local/share/fnm
ENV PATH=/app/node_modules/.bin:$FNM_DIR/aliases/default/bin:$PATH

# hadolint ignore=DL3066
USER noddy
ENV NODE_ENV=production
RUN npm config set update-notifier false
