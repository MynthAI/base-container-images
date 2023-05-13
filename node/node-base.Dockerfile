FROM ubuntu:22.04 as base

ARG NODE_VERSION=20.1.0
ARG NODE_DISTRO=linux-x64

FROM base as build

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ADD https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-${NODE_DISTRO}.tar.gz .
RUN mkdir -p /usr/local/lib/nodejs && \
    tar -xzf "node-v${NODE_VERSION}-${NODE_DISTRO}.tar.gz" \
        -C /usr/local/lib/nodejs && \
    rm "node-v${NODE_VERSION}-${NODE_DISTRO}.tar.gz"

FROM base
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

RUN useradd --create-home --shell /bin/bash noddy

COPY --from=build /usr/local/lib/nodejs /usr/local/lib/nodejs
ENV PATH /usr/local/lib/nodejs/node-v${NODE_VERSION}-${NODE_DISTRO}/bin:$PATH

USER noddy
