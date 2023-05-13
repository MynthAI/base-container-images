FROM ubuntu:22.04 as tini

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

FROM ubuntu:22.04
COPY --from=tini /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

RUN useradd --create-home --shell /bin/bash monty

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends python3.11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1
ENV PATH /app/.venv/bin:$PATH

# hadolint ignore=DL3008,DL3009
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        python3.11-venv && \
    python3.11 -m venv /opt/poetry && \
    /opt/poetry/bin/pip install poetry && \
    ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry

COPY install-poetry-app.sh /usr/local/bin/install-poetry-app
RUN chmod +x /usr/local/bin/install-poetry-app && \
    mkdir /app && \
    chown -R monty:monty /app

USER monty
WORKDIR /app
RUN poetry config virtualenvs.in-project true
