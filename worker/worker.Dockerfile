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
RUN npm install -g corepack@0.35.0

FROM ghcr.io/astral-sh/uv:0.12.5 AS uv

FROM ubuntu:26.04 AS python

COPY --from=uv /uv /uvx /usr/local/bin/

ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python

RUN uv python install 3.14.7 --no-cache

FROM ubuntu:26.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

COPY --from=build /usr/local/bin/fnm /usr/local/bin/fnm
COPY --from=build /usr/local/share/fnm /usr/local/share/fnm
COPY --from=uv /uv /uvx /usr/local/bin/
COPY --from=python /opt/uv/python /opt/uv/python

RUN ln -s /opt/uv/python/cpython-3.14-*/bin/python3.14 /usr/local/bin/python3.14 && \
    ln -s /usr/local/bin/python3.14 /usr/local/bin/python3 && \
    ln -s /usr/local/bin/python3.14 /usr/local/bin/python && \
    useradd --create-home --shell /bin/bash worker && \
    mkdir /app && \
    chown -R worker:worker /app

ENV FNM_DIR=/usr/local/share/fnm
ENV PNPM_HOME=/home/worker/.local/share/pnpm
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1
ENV PATH=/app/.venv/bin:$PNPM_HOME:/app/node_modules/.bin:$FNM_DIR/aliases/default/bin:$PATH
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
ENV UV_PYTHON_PREFERENCE=only-managed

# Core CLI utilities (git, curl, ripgrep, jq, zip, unzip, file,
# pandoc, pkg-config, sqlite3) so tasks have the tooling an AI agent needs
# out of the box. Recommended packages are installed as well so the
# tools are fully functional out of the box. Node.js 26 requires
# libatomic.so.1, so apt runs before corepack/npm
# hadolint ignore=DL3008,DL3015
RUN apt-get update -qq && \
    apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        file \
        git \
        jq \
        libatomic1 \
        pandoc \
        pkg-config \
        ripgrep \
        sqlite3 \
        sudo \
        unzip \
        zip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    corepack enable && \
    corepack prepare pnpm@11.22.0 --activate && \
    npm install -g node-gyp@13.0.1 turbo@2.10.10

# Passwordless sudo lets the worker user modify its environment at runtime
RUN echo 'worker ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/worker && \
    chmod 0440 /etc/sudoers.d/worker && \
    visudo -cf /etc/sudoers.d/worker

RUN UV_TOOL_DIR=/opt/uv/tools UV_TOOL_BIN_DIR=/usr/local/bin \
    uv tool install poethepoet==0.48.0

COPY python/install-uv-app.sh /usr/local/bin/install-uv-app
RUN chmod +x /usr/local/bin/install-uv-app

# hadolint ignore=DL3066
USER worker
ENV NODE_ENV=development
WORKDIR /app
RUN npm config set update-notifier false
