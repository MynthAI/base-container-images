FROM ubuntu:24.04 as tini

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

FROM ubuntu:24.04
COPY --from=tini /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

# hadolint ignore=DL3022
COPY --from=quay.io/mynth/docker-vault-cli:python \
    /dist /

RUN useradd --create-home --shell /bin/bash monty

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends python3.12 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1
ENV PATH /app/.venv/bin:$PATH

USER monty
