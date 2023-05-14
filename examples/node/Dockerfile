FROM quay.io/mynth/node:base as builder

# Build the project
WORKDIR /app
COPY --chown=noddy:noddy package*.json ./
RUN npm ci

COPY --chown=noddy:noddy . ./
RUN npx next build && npm prune --production

FROM quay.io/mynth/node:base
WORKDIR /app
COPY --from=builder --chown=noddy:noddy /app ./
EXPOSE 3000
CMD ["next", "start"]
