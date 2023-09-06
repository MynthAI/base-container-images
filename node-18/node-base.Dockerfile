FROM ubuntu:22.04 as build

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ADD https://nodejs.org/dist/v18.17.0/node-v18.17.0-linux-x64.tar.gz .
RUN mkdir -p /usr/local/lib/nodejs && \
    tar -xzf node-v18.17.0-linux-x64.tar.gz \
        -C /usr/local/lib/nodejs && \
    rm node-v18.17.0-linux-x64.tar.gz
ENV PATH /usr/local/lib/nodejs/node-v18.17.0-linux-x64/bin:$PATH

# RUN npm install -g npm@9.8.1

FROM ubuntu:22.04
COPY --from=build /tini /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

RUN useradd --create-home --shell /bin/bash noddy && \
    mkdir /app && \
    chown -R noddy:noddy /app   

COPY --from=build /usr/local/lib/nodejs /usr/local/lib/nodejs

ENV PATH /app/node_modules/.bin:/usr/local/lib/nodejs/node-v18.17.0-linux-x64/bin:$PATH

# Install Python
RUN apt-get update && apt install -y python3.10-venv

RUN mkdir ~/.vault-cli && \
    python3 -m venv ~/.vault-cli/venv  && \
    ~/.vault-cli/venv/bin/pip install vault-cli && \    
    sudo ln -s ~/.vault-cli/venv/bin/vault-cli /usr/local/bin

USER noddy
ENV NODE_ENV production


