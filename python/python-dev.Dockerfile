FROM ubuntu:24.04 AS tini

ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

FROM ubuntu:24.04
COPY --from=tini /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

# hadolint ignore=DL3022
COPY --from=quay.io/mynth/docker-vault-cli /usr/local/bin/vault-cli /usr/local/bin/vault-cli

RUN useradd --create-home --shell /bin/bash monty

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends python3.12 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1
ENV PATH=/app/.venv/bin:$PATH

# hadolint ignore=DL3008,DL3009
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        python3.12-venv && \
    python3.12 -m venv /opt/poetry && \
    /opt/poetry/bin/pip install poetry && \
    ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry

COPY install-poetry-app.sh /usr/local/bin/install-poetry-app
RUN chmod +x /usr/local/bin/install-poetry-app && \
    mkdir /app && \
    chown -R monty:monty /app

USER monty
WORKDIR /app
RUN poetry config virtualenvs.in-project true
