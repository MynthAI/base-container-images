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
    apt-get install -y --no-install-recommends ca-certificates unzip libatomic1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    unzip fnm-linux.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/fnm && \
    rm fnm-linux.zip

RUN fnm install ${NODE_VERSION} && \
    fnm default ${NODE_VERSION}

ENV PATH=$FNM_DIR/aliases/default/bin:$PATH
RUN npm install -g corepack@0.35.0 && \
    npm config set update-notifier false

FROM ubuntu:26.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

RUN useradd --create-home --shell /bin/bash noddy && \
    mkdir /app && \
    chown -R noddy:noddy /app

COPY --from=build /usr/local/bin/fnm /usr/local/bin/fnm
COPY --from=build /usr/local/share/fnm /usr/local/share/fnm
ENV FNM_DIR=/usr/local/share/fnm
ENV PNPM_HOME=/home/noddy/.local/share/pnpm
ENV PATH=$PNPM_HOME:/app/node_modules/.bin:$FNM_DIR/aliases/default/bin:$PATH

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
