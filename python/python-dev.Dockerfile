FROM quay.io/mynth/python-base:local

USER root

# hadolint ignore=DL3008,DL3009
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        python3.11-venv && \
    python3.11 -m venv /opt/poetry && \
    /opt/poetry/bin/pip install poetry && \
    ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry

COPY install-poetry-app.sh /usr/local/bin/install-poetry-app
RUN chmod +x /usr/local/bin/install-poetry-app

USER monty
WORKDIR /app
RUN poetry config virtualenvs.in-project true
