FROM quay.io/mynth/node:18-dev AS builder

# Build the project
WORKDIR /app
COPY --chown=noddy:noddy package*.json ./
RUN npm ci

COPY --chown=noddy:noddy . ./
RUN npx next build && npm ci --omit dev

FROM quay.io/mynth/node:18-base
WORKDIR /app
COPY --from=builder --chown=noddy:noddy /app ./
EXPOSE 3000
CMD ["next", "start"]
