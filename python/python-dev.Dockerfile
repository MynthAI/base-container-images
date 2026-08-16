FROM ubuntu:26.04 AS tini

ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

FROM ghcr.io/astral-sh/uv:0.12.5 AS uv

FROM ubuntu:26.04 AS python

COPY --from=uv /uv /uvx /usr/local/bin/

ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python

RUN uv python install 3.14.7 --no-cache

FROM ubuntu:26.04
COPY --from=tini /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

COPY --from=uv /uv /uvx /usr/local/bin/

COPY --from=python /opt/uv/python /opt/uv/python

RUN ln -s /opt/uv/python/cpython-3.14-*/bin/python3.14 /usr/local/bin/python3.14 && \
    ln -s /usr/local/bin/python3.14 /usr/local/bin/python3 && \
    ln -s /usr/local/bin/python3.14 /usr/local/bin/python && \
    useradd --create-home --shell /bin/bash monty

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1
ENV PATH=/app/.venv/bin:$PATH
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
ENV UV_PYTHON_PREFERENCE=only-managed

RUN UV_TOOL_DIR=/opt/uv/tools UV_TOOL_BIN_DIR=/usr/local/bin \
    uv tool install poethepoet==0.48.0

COPY install-uv-app.sh /usr/local/bin/install-uv-app
RUN chmod +x /usr/local/bin/install-uv-app && \
    mkdir /app && \
    chown -R monty:monty /app

# hadolint ignore=DL3066
USER monty
WORKDIR /app
